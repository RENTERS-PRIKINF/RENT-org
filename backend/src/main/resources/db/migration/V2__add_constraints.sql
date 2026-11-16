
-- V2: Constraints, relationships, and triggersand indexes.
-- Based on rent_schema.sql; primary keys are already created in V1.

-- 1. UNIQUE constraints
ALTER TABLE ONLY public.landlords
    ADD CONSTRAINT landlords_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.meter_readings
    ADD CONSTRAINT uq_meter_reading_date UNIQUE (meter_id, reading_date);

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT uq_meter_serial UNIQUE (serial_number);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


-- 2. CHECK constraints
ALTER TABLE public.leases
    ADD CONSTRAINT chk_lease_amount
    CHECK (rent_amount > 0);

ALTER TABLE public.leases
    ADD CONSTRAINT chk_lease_dates
    CHECK (contract_end_at > start_at);

ALTER TABLE public.meter_readings
    ADD CONSTRAINT chk_reading_value
    CHECK (value >= 0);

ALTER TABLE public.payments
    ADD CONSTRAINT chk_payment_amount
    CHECK (amount > 0);

ALTER TABLE public.payments
    ADD CONSTRAINT chk_payment_direction
    CHECK (
        (type = 'rent' AND direction = 'income')
        OR (type = 'deposit' AND direction = 'income')
        OR (type = 'deposit_return' AND direction = 'expense')
        OR (type = 'repair')
        OR (type = 'penalty' AND direction = 'income')
        OR (type = 'other')
    );

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_area
    CHECK (area > 0);

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_rooms
    CHECK (rooms > 0);

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_floor
    CHECK (floor IS NULL OR floor >= 0);

ALTER TABLE public.leases
    ADD CONSTRAINT chk_lease_deposit
    CHECK (deposit_amount IS NULL OR deposit_amount > 0);

ALTER TABLE public.contract_templates
    ADD CONSTRAINT chk_template_version
    CHECK (version > 0);


-- 3. FOREIGN KEY constraints
ALTER TABLE ONLY public.contract_templates
    ADD CONSTRAINT contract_templates_owner_id_fkey
    FOREIGN KEY (owner_id)
    REFERENCES public.landlords(landlord_id)
    ON DELETE SET NULL;

ALTER TABLE ONLY public.flats
    ADD CONSTRAINT flats_landlord_id_fkey
    FOREIGN KEY (landlord_id)
    REFERENCES public.landlords(landlord_id)
    ON DELETE RESTRICT;

ALTER TABLE ONLY public.landlords
    ADD CONSTRAINT landlords_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public.users(user_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.lease_amendments
    ADD CONSTRAINT lease_amendments_contract_id_fkey
    FOREIGN KEY (contract_id)
    REFERENCES public.contracts(contract_id)
    ON DELETE SET NULL;

ALTER TABLE ONLY public.lease_amendments
    ADD CONSTRAINT lease_amendments_lease_id_fkey
    FOREIGN KEY (lease_id)
    REFERENCES public.leases(lease_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.leases
    ADD CONSTRAINT leases_contract_id_fkey
    FOREIGN KEY (contract_id)
    REFERENCES public.contracts(contract_id)
    ON DELETE SET NULL;

ALTER TABLE ONLY public.leases
    ADD CONSTRAINT leases_flat_id_fkey
    FOREIGN KEY (flat_id)
    REFERENCES public.flats(flat_id)
    ON DELETE RESTRICT;

ALTER TABLE ONLY public.leases
    ADD CONSTRAINT leases_handover_act_id_fkey
    FOREIGN KEY (handover_act_id)
    REFERENCES public.contracts(contract_id)
    ON DELETE SET NULL;

ALTER TABLE ONLY public.leases
    ADD CONSTRAINT leases_return_act_id_fkey
    FOREIGN KEY (return_act_id)
    REFERENCES public.contracts(contract_id)
    ON DELETE SET NULL;

ALTER TABLE ONLY public.leases
    ADD CONSTRAINT leases_tenant_id_fkey
    FOREIGN KEY (tenant_id)
    REFERENCES public.tenants(tenant_id)
    ON DELETE RESTRICT;

ALTER TABLE ONLY public.meter_readings
    ADD CONSTRAINT meter_readings_entered_by_fkey
    FOREIGN KEY (entered_by)
    REFERENCES public.users(user_id)
    ON DELETE RESTRICT;

ALTER TABLE ONLY public.meter_readings
    ADD CONSTRAINT meter_readings_meter_id_fkey
    FOREIGN KEY (meter_id)
    REFERENCES public.meters(meter_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_flat_id_fkey
    FOREIGN KEY (flat_id)
    REFERENCES public.flats(flat_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public.users(user_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_lease_id_fkey
    FOREIGN KEY (lease_id)
    REFERENCES public.leases(lease_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.property_media
    ADD CONSTRAINT property_media_flat_id_fkey
    FOREIGN KEY (flat_id)
    REFERENCES public.flats(flat_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_flat_id_fkey
    FOREIGN KEY (flat_id)
    REFERENCES public.flats(flat_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_tenant_id_fkey
    FOREIGN KEY (tenant_id)
    REFERENCES public.tenants(tenant_id)
    ON DELETE CASCADE;

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public.users(user_id)
    ON DELETE CASCADE;


-- 4. Business unique index
CREATE UNIQUE INDEX one_active_lease_per_flat
    ON public.leases (flat_id)
    WHERE status = 'active'::public.rent_status;


-- 5. Trigger functions
CREATE FUNCTION public.trg_lease_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- При создании/активации договора — квартира "сдана"
    IF NEW.status = 'active' THEN
        UPDATE public.flats
        SET status = 'rented'
        WHERE flat_id = NEW.flat_id;
    END IF;

    -- При завершении/расторжении — квартира "свободна"
    IF NEW.status IN ('finished', 'terminated') THEN
        UPDATE public.flats
        SET status = 'available'
        WHERE flat_id = NEW.flat_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_requests_resolved_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status IN ('done', 'rejected')
       AND NEW.resolved_at IS NULL THEN
        NEW.resolved_at := NOW();
    ELSIF NEW.status NOT IN ('done', 'rejected') THEN
        NEW.resolved_at := NULL;
    END IF;

    RETURN NEW;
END;
$$;


-- 6. Triggers
CREATE TRIGGER trg_lease_status_change
    AFTER INSERT OR UPDATE OF status
    ON public.leases
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_lease_status_change();

CREATE TRIGGER trg_requests_status_change
    BEFORE UPDATE
    ON public.requests
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_requests_resolved_at();


-- 7. Indexes

CREATE INDEX idx_amendments_lease
    ON public.lease_amendments (lease_id);

CREATE INDEX idx_contracts_kind
    ON public.contracts (doc_kind);

CREATE INDEX idx_flats_landlord
    ON public.flats (landlord_id);

CREATE INDEX idx_flats_status
    ON public.flats (status);

CREATE INDEX idx_leases_end_date
    ON public.leases (contract_end_at);

CREATE INDEX idx_leases_flat
    ON public.leases (flat_id);

CREATE INDEX idx_leases_status
    ON public.leases (status);

CREATE INDEX idx_leases_tenant
    ON public.leases (tenant_id);

CREATE INDEX idx_meters_flat
    ON public.meters (flat_id);

CREATE INDEX idx_meters_type
    ON public.meters (meter_type);

CREATE INDEX idx_notifications_scheduled
    ON public.notifications (scheduled_at);

CREATE INDEX idx_notifications_status
    ON public.notifications (status);

CREATE INDEX idx_notifications_user
    ON public.notifications (user_id);

CREATE INDEX idx_payments_date
    ON public.payments (payment_date);

CREATE INDEX idx_payments_dir
    ON public.payments (direction);

CREATE INDEX idx_payments_lease
    ON public.payments (lease_id);

CREATE INDEX idx_payments_type
    ON public.payments (type);

CREATE INDEX idx_pmedia_flat
    ON public.property_media (flat_id);

CREATE INDEX idx_readings_date
    ON public.meter_readings (reading_date);

CREATE INDEX idx_readings_user
    ON public.meter_readings (entered_by);

CREATE INDEX idx_requests_flat
    ON public.requests (flat_id);

CREATE INDEX idx_requests_status
    ON public.requests (status);

CREATE INDEX idx_requests_tenant
    ON public.requests (tenant_id);

CREATE INDEX idx_templates_owner
    ON public.contract_templates (owner_id);

CREATE INDEX idx_templates_type
    ON public.contract_templates (type);

CREATE INDEX idx_users_role
    ON public.users (role);
