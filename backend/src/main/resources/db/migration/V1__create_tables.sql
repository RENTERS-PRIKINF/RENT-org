
-- 1. ENUM

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


-- 2. TABLES

CREATE TABLE public.contract_templates (
    template_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    type public.doc_type NOT NULL,
    file_url character varying(500) NOT NULL,
    owner_id bigint,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT contract_templates_pkey PRIMARY KEY (template_id)
);

CREATE TABLE public.contracts (
    contract_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    doc_kind public.doc_type NOT NULL,
    file_url character varying(500) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
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
    tax_id character varying(50),
    notes text,
    CONSTRAINT landlords_pkey PRIMARY KEY (landlord_id)
);

CREATE TABLE public.lease_amendments (
    amendment_id bigint NOT NULL,
    lease_id bigint NOT NULL,
    contract_id bigint,
    change_date date NOT NULL,
    description text,
    CONSTRAINT lease_amendments_pkey PRIMARY KEY (amendment_id)
);

CREATE TABLE public.leases (
    lease_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    tenant_id bigint NOT NULL,
    contract_id bigint,
    handover_act_id bigint,
    return_act_id bigint,
    start_at timestamp with time zone NOT NULL,
    contract_end_at timestamp with time zone NOT NULL,
    rent_amount numeric(12,2) NOT NULL,
    deposit_amount numeric(12,2),
    status public.rent_status DEFAULT 'pending'::public.rent_status NOT NULL,
    rent_period public.rent_period NOT NULL,
    CONSTRAINT leases_pkey PRIMARY KEY (lease_id)
);

CREATE TABLE public.meter_readings (
    reading_id bigint NOT NULL,
    meter_id bigint NOT NULL,
    reading_date date NOT NULL,
    value numeric(12,3) NOT NULL,
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
    scheduled_at timestamp without time zone NOT NULL,
    sent_at timestamp without time zone,
    status public.notification_status DEFAULT 'pending'::public.notification_status NOT NULL,
    CONSTRAINT notifications_pkey PRIMARY KEY (notification_id)
);

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    lease_id bigint NOT NULL,
    payment_date date NOT NULL,
    amount numeric(12,2) NOT NULL,
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
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT property_media_pkey PRIMARY KEY (media_id)
);

CREATE TABLE public.requests (
    request_id bigint NOT NULL,
    flat_id bigint NOT NULL,
    tenant_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    description text NOT NULL,
    status public.request_status DEFAULT 'new'::public.request_status NOT NULL,
    resolved_at timestamp without time zone,
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
    phone character varying(50),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
);


-- 3. SEQUENCES

CREATE SEQUENCE public.contract_templates_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.contracts_contract_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.flats_flat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.landlords_landlord_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.lease_amendments_amendment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.leases_lease_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.meter_readings_reading_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.meters_meter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.notifications_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.property_media_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.requests_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.tenants_tenant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- 4. SEQUENCE OWNERSHIP

ALTER SEQUENCE public.contract_templates_template_id_seq
    OWNED BY public.contract_templates.template_id;

ALTER SEQUENCE public.contracts_contract_id_seq
    OWNED BY public.contracts.contract_id;

ALTER SEQUENCE public.flats_flat_id_seq
    OWNED BY public.flats.flat_id;

ALTER SEQUENCE public.landlords_landlord_id_seq
    OWNED BY public.landlords.landlord_id;

ALTER SEQUENCE public.lease_amendments_amendment_id_seq
    OWNED BY public.lease_amendments.amendment_id;

ALTER SEQUENCE public.leases_lease_id_seq
    OWNED BY public.leases.lease_id;

ALTER SEQUENCE public.meter_readings_reading_id_seq
    OWNED BY public.meter_readings.reading_id;

ALTER SEQUENCE public.meters_meter_id_seq
    OWNED BY public.meters.meter_id;

ALTER SEQUENCE public.notifications_notification_id_seq
    OWNED BY public.notifications.notification_id;

ALTER SEQUENCE public.payments_payment_id_seq
    OWNED BY public.payments.payment_id;

ALTER SEQUENCE public.property_media_media_id_seq
    OWNED BY public.property_media.media_id;

ALTER SEQUENCE public.requests_request_id_seq
    OWNED BY public.requests.request_id;

ALTER SEQUENCE public.tenants_tenant_id_seq
    OWNED BY public.tenants.tenant_id;

ALTER SEQUENCE public.users_user_id_seq
    OWNED BY public.users.user_id;


-- 5. DEFAULT ID GENERATION

ALTER TABLE ONLY public.contract_templates
    ALTER COLUMN template_id
    SET DEFAULT nextval('public.contract_templates_template_id_seq'::regclass);

ALTER TABLE ONLY public.contracts
    ALTER COLUMN contract_id
    SET DEFAULT nextval('public.contracts_contract_id_seq'::regclass);

ALTER TABLE ONLY public.flats
    ALTER COLUMN flat_id
    SET DEFAULT nextval('public.flats_flat_id_seq'::regclass);

ALTER TABLE ONLY public.landlords
    ALTER COLUMN landlord_id
    SET DEFAULT nextval('public.landlords_landlord_id_seq'::regclass);

ALTER TABLE ONLY public.lease_amendments
    ALTER COLUMN amendment_id
    SET DEFAULT nextval('public.lease_amendments_amendment_id_seq'::regclass);

ALTER TABLE ONLY public.leases
    ALTER COLUMN lease_id
    SET DEFAULT nextval('public.leases_lease_id_seq'::regclass);

ALTER TABLE ONLY public.meter_readings
    ALTER COLUMN reading_id
    SET DEFAULT nextval('public.meter_readings_reading_id_seq'::regclass);

ALTER TABLE ONLY public.meters
    ALTER COLUMN meter_id
    SET DEFAULT nextval('public.meters_meter_id_seq'::regclass);

ALTER TABLE ONLY public.notifications
    ALTER COLUMN notification_id
    SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);

ALTER TABLE ONLY public.payments
    ALTER COLUMN payment_id
    SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);

ALTER TABLE ONLY public.property_media
    ALTER COLUMN media_id
    SET DEFAULT nextval('public.property_media_media_id_seq'::regclass);

ALTER TABLE ONLY public.requests
    ALTER COLUMN request_id
    SET DEFAULT nextval('public.requests_request_id_seq'::regclass);

ALTER TABLE ONLY public.tenants
    ALTER COLUMN tenant_id
    SET DEFAULT nextval('public.tenants_tenant_id_seq'::regclass);

ALTER TABLE ONLY public.users
    ALTER COLUMN user_id
    SET DEFAULT nextval('public.users_user_id_seq'::regclass);
