-- V2: Constraints, triggers, and indexes based on the corrected schema.
-- All existing ON DELETE rules preserved; extra CHECKs agreed by team.

-- UNIQUE constraints

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

-- CHECK constraints
ALTER TABLE public.rents
    ADD CONSTRAINT chk_rent_amount CHECK ((rent_amount > (0)::numeric));

ALTER TABLE public.rents
    ADD CONSTRAINT chk_rent_dates CHECK ((end_at > start_at));

ALTER TABLE public.meter_readings
    ADD CONSTRAINT chk_reading_value CHECK ((value >= (0)::numeric));

ALTER TABLE public.payments
    ADD CONSTRAINT chk_payment_amount CHECK ((amount > (0)::numeric));

ALTER TABLE public.payments
    ADD CONSTRAINT chk_payment_direction CHECK ((((type = 'rent'::public.payment_type) AND (direction = 'income'::public.payment_direction)) OR ((type = 'deposit'::public.payment_type) AND (direction = 'income'::public.payment_direction)) OR ((type = 'deposit_return'::public.payment_type) AND (direction = 'expense'::public.payment_direction)) OR (type = 'repair'::public.payment_type) OR ((type = 'penalty'::public.payment_type) AND (direction = 'income'::public.payment_direction)) OR (type = 'other'::public.payment_type)));

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_area CHECK (area > 0);

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_rooms CHECK (rooms > 0);

ALTER TABLE public.flats
    ADD CONSTRAINT chk_flat_floor CHECK (floor IS NULL OR floor >= 0);

ALTER TABLE public.rents
    ADD CONSTRAINT chk_rent_deposit CHECK (deposit_amount IS NULL OR deposit_amount > 0);

ALTER TABLE public.contract_templates
    ADD CONSTRAINT chk_template_version CHECK (version > 0);

-- FOREIGN KEY constraints
ALTER TABLE ONLY public.contract_templates
    ADD CONSTRAINT contract_templates_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.landlords(landlord_id) ON DELETE SET NULL;

ALTER TABLE ONLY public.flats
    ADD CONSTRAINT flats_landlord_id_fkey FOREIGN KEY (landlord_id) REFERENCES public.landlords(landlord_id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.landlords
    ADD CONSTRAINT landlords_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.rent_amendments
    ADD CONSTRAINT rent_amendments_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(contract_id) ON DELETE SET NULL;

ALTER TABLE ONLY public.rent_amendments
    ADD CONSTRAINT rent_amendments_rent_id_fkey FOREIGN KEY (rent_id) REFERENCES public.rents(rent_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(contract_id) ON DELETE SET NULL;

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_flat_id_fkey FOREIGN KEY (flat_id) REFERENCES public.flats(flat_id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_handover_act_id_fkey FOREIGN KEY (handover_act_id) REFERENCES public.contracts(contract_id) ON DELETE SET NULL;

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_return_act_id_fkey FOREIGN KEY (return_act_id) REFERENCES public.contracts(contract_id) ON DELETE SET NULL;

ALTER TABLE ONLY public.rents
    ADD CONSTRAINT rents_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.meter_readings
    ADD CONSTRAINT meter_readings_entered_by_fkey FOREIGN KEY (entered_by) REFERENCES public.users(user_id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.meter_readings
    ADD CONSTRAINT meter_readings_meter_id_fkey FOREIGN KEY (meter_id) REFERENCES public.meters(meter_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_flat_id_fkey FOREIGN KEY (flat_id) REFERENCES public.flats(flat_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_rent_id_fkey FOREIGN KEY (rent_id) REFERENCES public.rents(rent_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.property_media
    ADD CONSTRAINT property_media_flat_id_fkey FOREIGN KEY (flat_id) REFERENCES public.flats(flat_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_flat_id_fkey FOREIGN KEY (flat_id) REFERENCES public.flats(flat_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;

-- Business unique index
CREATE UNIQUE INDEX one_active_rent_per_flat ON public.rents USING btree (flat_id) WHERE (status = 'active'::public.rent_status);

-- Trigger functions
CREATE FUNCTION public.trg_rent_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- При создании/активации договора — квартира "сдана"
    IF NEW.status = 'active' THEN
        UPDATE flats SET status = 'rented' WHERE flat_id = NEW.flat_id;
    END IF;

    -- При завершении/расторжении — квартира "свободна"
    IF NEW.status IN ('finished', 'terminated') THEN
        UPDATE flats SET status = 'available' WHERE flat_id = NEW.flat_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_requests_resolved_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status IN ('done', 'rejected') AND NEW.resolved_at IS NULL THEN
        NEW.resolved_at := NOW();
    ELSIF NEW.status NOT IN ('done', 'rejected') THEN
        NEW.resolved_at := NULL;
    END IF;
    RETURN NEW;
END;
$$;

-- Triggers
CREATE TRIGGER trg_rent_status_change AFTER INSERT OR UPDATE OF status ON public.rents FOR EACH ROW EXECUTE FUNCTION public.trg_rent_status_change();

CREATE TRIGGER trg_requests_status_change BEFORE UPDATE ON public.requests FOR EACH ROW EXECUTE FUNCTION public.trg_requests_resolved_at();

-- Indexes (excluding redundant indexes)
CREATE INDEX idx_amendments_rent ON public.rent_amendments USING btree (rent_id);

CREATE INDEX idx_contracts_kind ON public.contracts USING btree (doc_type);

CREATE INDEX idx_flats_landlord ON public.flats USING btree (landlord_id);

CREATE INDEX idx_flats_status ON public.flats USING btree (status);

CREATE INDEX idx_rents_end_date ON public.rents USING btree (end_at);

CREATE INDEX idx_rents_flat ON public.rents USING btree (flat_id);

CREATE INDEX idx_rents_status ON public.rents USING btree (status);

CREATE INDEX idx_rents_tenant ON public.rents USING btree (tenant_id);

CREATE INDEX idx_meters_flat ON public.meters USING btree (flat_id);

CREATE INDEX idx_meters_type ON public.meters USING btree (meter_type);

CREATE INDEX idx_notifications_scheduled ON public.notifications USING btree (scheduled_at);

CREATE INDEX idx_notifications_status ON public.notifications USING btree (status);

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);

CREATE INDEX idx_payments_date ON public.payments USING btree (payment_date);

CREATE INDEX idx_payments_dir ON public.payments USING btree (direction);

CREATE INDEX idx_payments_rent ON public.payments USING btree (rent_id);

CREATE INDEX idx_payments_type ON public.payments USING btree (type);

CREATE INDEX idx_pmedia_flat ON public.property_media USING btree (flat_id);

CREATE INDEX idx_readings_date ON public.meter_readings USING btree (reading_date);

CREATE INDEX idx_readings_user ON public.meter_readings USING btree (entered_by);

CREATE INDEX idx_requests_flat ON public.requests USING btree (flat_id);

CREATE INDEX idx_requests_status ON public.requests USING btree (status);

CREATE INDEX idx_requests_tenant ON public.requests USING btree (tenant_id);

CREATE INDEX idx_templates_owner ON public.contract_templates USING btree (owner_id);

CREATE INDEX idx_templates_type ON public.contract_templates USING btree (type);

CREATE INDEX idx_users_role ON public.users USING btree (role);

