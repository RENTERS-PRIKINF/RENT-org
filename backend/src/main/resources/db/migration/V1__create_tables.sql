-- V1: Schema based on blyatskiypostgres.sql (PostgreSQL 18 dump).
-- Normalized named NOT NULL constraints for compatibility with PostgreSQL 17.
-- ID columns use GENERATED ALWAYS AS IDENTITY.

-- Enum types
CREATE TYPE public.doc_type AS ENUM (
    'lease',
    'act_handover',
    'act_return',
    'amendment'
);

CREATE TYPE public.flat_status AS ENUM (
    'available',
    'rented',
    'renovation',
    'booked'
);

CREATE TYPE public.media_type AS ENUM (
    'picture',
    'video'
);

CREATE TYPE public.meter_type AS ENUM (
    'electricity',
    'water_cold',
    'water_hot',
    'gas'
);

CREATE TYPE public.notification_status AS ENUM (
    'pending',
    'sent',
    'failed'
);

CREATE TYPE public.notification_type AS ENUM (
    'payment',
    'contract',
    'meter',
    'inspection'
);

CREATE TYPE public.payment_direction AS ENUM (
    'income',
    'expense'
);

CREATE TYPE public.payment_type AS ENUM (
    'rent',
    'deposit',
    'deposit_return',
    'repair',
    'penalty',
    'other'
);

CREATE TYPE public.rent_period AS ENUM (
    'hourly',
    'daily',
    'monthly'
);

CREATE TYPE public.rent_status AS ENUM (
    'active',
    'finished',
    'terminated',
    'pending'
);

CREATE TYPE public.request_status AS ENUM (
    'new',
    'pending',
    'done',
    'rejected'
);

CREATE TYPE public.user_role AS ENUM (
    'landlord',
    'tenant'
);

-- Tables and primary keys
CREATE TABLE public.contract_templates (
    template_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type public.doc_type NOT NULL,
    file_url character varying(500) NOT NULL,
    owner_id bigint,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT contract_templates_pkey PRIMARY KEY (template_id)
);

CREATE TABLE public.contracts (
    contract_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    doc_type public.doc_type NOT NULL,
    file_url character varying(500) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT contracts_pkey PRIMARY KEY (contract_id)
);

CREATE TABLE public.flats (
    flat_id bigint NOT NULL,
    landlord_id bigint NOT NULL,
    address character varying(250) NOT NULL,
    area double precision NOT NULL,
    rooms integer NOT NULL,
    floor integer,
    cadastral_number character varying(25),
    status public.flat_status DEFAULT 'available'::public.flat_status NOT NULL,
    description character varying(1000),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT flats_pkey PRIMARY KEY (flat_id)
);

CREATE TABLE public.landlords (
    landlord_id bigint NOT NULL,
    user_id bigint NOT NULL,
    company_name character varying(255),
    notes text,
    CONSTRAINT landlords_pkey PRIMARY KEY (landlord_id)
);

CREATE TABLE public.rent_amendments (
    amendment_id bigint NOT NULL,
    rent_id bigint NOT NULL,
    contract_id bigint,
    change_date date DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT lease_amendments_pkey PRIMARY KEY (amendment_id)
);

CREATE TABLE public.rents (
    rent_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    tenant_id bigint NOT NULL,
    contract_id bigint,
    handover_act_id bigint,
    return_act_id bigint,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    rent_amount numeric(15,2) NOT NULL,
    deposit_amount numeric(15,2),
    status public.rent_status DEFAULT 'pending'::public.rent_status NOT NULL,
    rent_period public.rent_period NOT NULL,
    CONSTRAINT leases_pkey PRIMARY KEY (rent_id)
);

CREATE TABLE public.meter_readings (
    reading_id bigint NOT NULL,
    meter_id bigint NOT NULL,
    reading_date date DEFAULT now() NOT NULL,
    value numeric(15,3) NOT NULL,
    photo_url character varying(500),
    entered_by bigint NOT NULL,
    CONSTRAINT meter_readings_pkey PRIMARY KEY (reading_id)
);

CREATE TABLE public.meters (
    meter_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    meter_type public.meter_type NOT NULL,
    serial_number character varying(100) NOT NULL,
    verification_date date,
    CONSTRAINT meters_pkey PRIMARY KEY (meter_id)
);

CREATE TABLE public.notifications (
    notification_id bigint NOT NULL,
    user_id bigint NOT NULL,
    type public.notification_type NOT NULL,
    message text NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    status public.notification_status DEFAULT 'pending'::public.notification_status NOT NULL,
    CONSTRAINT notifications_pkey PRIMARY KEY (notification_id)
);

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    rent_id bigint NOT NULL,
    payment_date date DEFAULT now() NOT NULL,
    amount numeric(15,2) NOT NULL,
    type public.payment_type NOT NULL,
    direction public.payment_direction NOT NULL,
    comment text,
    CONSTRAINT payments_pkey PRIMARY KEY (payment_id)
);

CREATE TABLE public.property_media (
    media_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    file_url character varying(500) NOT NULL,
    media_type public.media_type NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT property_media_pkey PRIMARY KEY (media_id)
);

CREATE TABLE public.requests (
    request_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    tenant_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text NOT NULL,
    status public.request_status DEFAULT 'new'::public.request_status NOT NULL,
    resolved_at timestamp with time zone,
    CONSTRAINT requests_pkey PRIMARY KEY (request_id)
);

CREATE TABLE public.tenants (
    tenant_id bigint NOT NULL,
    user_id bigint NOT NULL,
    passport_data character varying(255),
    notes text,
    CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id)
);

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    role public.user_role NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(15),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
);

-- Identity columns and their sequences
ALTER TABLE public.contract_templates ALTER COLUMN template_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contract_templates_template_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.contracts ALTER COLUMN contract_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contracts_contract_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.flats ALTER COLUMN flat_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.flats_flat_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.landlords ALTER COLUMN landlord_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.landlords_landlord_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.meter_readings ALTER COLUMN reading_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.meter_readings_reading_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.meters ALTER COLUMN meter_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.meters_meter_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.notifications ALTER COLUMN notification_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.notifications_notification_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_payment_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.property_media ALTER COLUMN media_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.property_media_media_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.rent_amendments ALTER COLUMN amendment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rent_amendments_amendment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.rents ALTER COLUMN rent_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rents_rent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.requests ALTER COLUMN request_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.requests_request_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.tenants ALTER COLUMN tenant_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tenants_tenant_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
