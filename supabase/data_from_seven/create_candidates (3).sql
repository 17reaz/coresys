-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.candidates (
  passport_no character varying NOT NULL UNIQUE,
  sl numeric UNIQUE,
  name text NOT NULL,
  received_date date,
  id uuid NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
  agent uuid,
  scan_copy text,
  created_by uuid DEFAULT '8b4c9815-5d68-4e0e-a13d-556a05433676'::uuid,
  is_deleted boolean DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  passport_returned boolean DEFAULT false,
  passport_returned_date date,
  current_stage USER-DEFINED,
  country USER-DEFINED,
  CONSTRAINT candidates_pkey PRIMARY KEY (id),
  CONSTRAINT candidates_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
  CONSTRAINT candidates_agent_fkey FOREIGN KEY (agent) REFERENCES public.agents(id)
);
CREATE TABLE public.agents (
  full_name text NOT NULL,
  CODE text,
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  barcode_code character varying,
  Is_active boolean,
  CONSTRAINT agents_pkey PRIMARY KEY (id)
);
CREATE TABLE public.agency (
  rl numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  name text,
  CONSTRAINT agency_pkey PRIMARY KEY (uuid)
);
CREATE TABLE public.passports (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT passports_pkey PRIMARY KEY (id)
);
CREATE TABLE public.medicals (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  sl bigint NOT NULL DEFAULT nextval('medicals_sl_seq'::regclass) UNIQUE,
  medical_date date,
  fit_date date,
  status text DEFAULT 'N/A'::text CHECK (status = ANY (ARRAY['N/A'::text, 'NEW'::text, 'FIT'::text, 'UNFIT'::text, 'USED'::text, 'EXPIRED'::text])),
  mofa_update boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT medicals_pkey PRIMARY KEY (id),
  CONSTRAINT medicals_candidate_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id)
);
CREATE TABLE public.visas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  visa_sl bigint NOT NULL DEFAULT nextval('visas_visa_sl_seq'::regclass) UNIQUE,
  issue_date date,
  expiry_date date,
  flight_date date,
  visa_type text,
  iqamah_number text,
  status text DEFAULT 'PENDING'::text CHECK (status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text, 'EXPIRED'::text, 'USED'::text])),
  created_at timestamp without time zone DEFAULT now(),
  agency uuid,
  manpower boolean,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  mofa_id uuid,
  CONSTRAINT visas_pkey PRIMARY KEY (id),
  CONSTRAINT visas_candidate_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT visas_agency_fkey FOREIGN KEY (agency) REFERENCES public.agency(uuid),
  CONSTRAINT visas_mofa_fkey FOREIGN KEY (mofa_id) REFERENCES public.mofas(id)
);
CREATE TABLE public.mofas (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sl integer NOT NULL DEFAULT nextval('mofa_sl_seq'::regclass) UNIQUE,
  candidate uuid NOT NULL,
  application_number character varying,
  agency uuid,
  med_update boolean DEFAULT false,
  trade text,
  aplication_date date,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  created_by uuid,
  medical_id uuid,
  pipeline_status USER-DEFINED NOT NULL DEFAULT 'MOFA_DONE'::mofa_pipeline_status,
  CONSTRAINT mofas_pkey PRIMARY KEY (id),
  CONSTRAINT mofa_candidate_fkey FOREIGN KEY (candidate) REFERENCES public.candidates(id),
  CONSTRAINT mofa_agency_fkey FOREIGN KEY (agency) REFERENCES public.agency(uuid),
  CONSTRAINT mofas_medical_id_fkey FOREIGN KEY (medical_id) REFERENCES public.medicals(id)
);
CREATE TABLE public.takamul (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  mofa_id uuid,
  trade text,
  test_center text,
  test_date date,
  result text DEFAULT 'PENDING'::text CHECK (result = ANY (ARRAY['PENDING'::text, 'PASS'::text, 'FAIL'::text, 'ABSENT'::text])),
  result_date date,
  certificate_no character varying UNIQUE,
  issue_date date,
  expiry_date date,
  status text DEFAULT 'PENDING'::text CHECK (status = ANY (ARRAY['PENDING'::text, 'SCHEDULED'::text, 'PASSED'::text, 'FAILED'::text, 'EXPIRED'::text, 'USED'::text])),
  document_url text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT takamul_pkey PRIMARY KEY (id),
  CONSTRAINT takamul_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT takamul_mofa_id_fkey FOREIGN KEY (mofa_id) REFERENCES public.mofas(id)
);
CREATE TABLE public.passport_tracking (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL UNIQUE,
  location text NOT NULL DEFAULT 'OFFICE'::text CHECK (location = ANY (ARRAY['OFFICE'::text, 'MEDICAL'::text, 'MOFA'::text, 'EMBASSY'::text, 'AGENCY'::text, 'CANDIDATE'::text, 'POLICE'::text, 'TAKAMUL'::text, 'COURIER'::text, 'OTHER'::text])),
  held_by text,
  phone text,
  received_date date,
  expected_return date,
  returned_date date,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT passport_tracking_pkey PRIMARY KEY (id),
  CONSTRAINT passport_tracking_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id)
);
CREATE TABLE public.passport_movements (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  from_location text,
  to_location text NOT NULL,
  movement_date date NOT NULL DEFAULT CURRENT_DATE,
  held_by text,
  phone text,
  expected_return date,
  reference_no text,
  notes text,
  created_by text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT passport_movements_pkey PRIMARY KEY (id),
  CONSTRAINT passport_movements_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id)
);
CREATE TABLE public.flights (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  flight_sl bigint NOT NULL DEFAULT nextval('flights_flight_sl_seq'::regclass) UNIQUE,
  visa_id uuid NOT NULL UNIQUE,
  delivery_date date,
  flight_date date,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT flights_pkey PRIMARY KEY (id),
  CONSTRAINT flights_visa_fkey FOREIGN KEY (visa_id) REFERENCES public.visas(id)
);
CREATE TABLE public.candidate_activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  candidate_id uuid NOT NULL,
  module_name character varying NOT NULL,
  action_type character varying NOT NULL,
  log_summary text NOT NULL,
  payload_meta text DEFAULT 'N/A'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT candidate_activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT candidate_activity_logs_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id)
);
CREATE TABLE public.barcodes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  barcode_value character varying NOT NULL UNIQUE,
  barcode_type character varying NOT NULL DEFAULT 'CODE128'::character varying,
  version integer NOT NULL DEFAULT 1,
  is_active boolean NOT NULL DEFAULT true,
  created_by uuid DEFAULT auth.uid(),
  is_deleted boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT barcodes_pkey PRIMARY KEY (id),
  CONSTRAINT barcodes_candidate_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT barcodes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.fingers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  process_type text NOT NULL DEFAULT 'fresh'::text CHECK (process_type = ANY (ARRAY['fresh'::text, 'already_done'::text])),
  appointment_date date,
  finger_date date,
  received_date date,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'scheduled'::text, 'completed'::text, 'failed'::text])),
  is_used boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  is_deleted boolean DEFAULT false,
  notes text,
  created_by uuid DEFAULT '8b4c9815-5d68-4e0e-a13d-556a05433676'::uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT fingers_pkey PRIMARY KEY (id),
  CONSTRAINT fingers_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id)
);
CREATE TABLE public.police_clearence (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  candidate_id uuid NOT NULL,
  issue_date date,
  received_at date,
  is_verified boolean NOT NULL DEFAULT false,
  is_used boolean NOT NULL DEFAULT false,
  notes text,
  is_deleted boolean NOT NULL DEFAULT false,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT police_clearence_pkey PRIMARY KEY (id),
  CONSTRAINT police_clearence_candidate_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT police_clearence_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.tenants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  sl bigint NOT NULL DEFAULT nextval('tenants_sl_seq'::regclass) UNIQUE,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  logo text,
  phone text,
  email text,
  country text DEFAULT 'Bangladesh'::text,
  timezone text DEFAULT 'Asia/Dhaka'::text,
  subscription_plan text NOT NULL DEFAULT 'FREE'::text CHECK (subscription_plan = ANY (ARRAY['FREE'::text, 'STARTER'::text, 'PRO'::text, 'BUSINESS'::text, 'ENTERPRISE'::text])),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tenants_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  tenant_id uuid NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'STAFF'::text CHECK (role = ANY (ARRAY['OWNER'::text, 'ADMIN'::text, 'MANAGER'::text, 'STAFF'::text])),
  phone text,
  avatar text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT profiles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
);
CREATE TABLE public.documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  candidate_id uuid NOT NULL,
  storage_path text NOT NULL,
  mime_type text,
  file_size bigint,
  version integer NOT NULL DEFAULT 1,
  is_current boolean NOT NULL DEFAULT true,
  notes text,
  uploaded_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  document_type USER-DEFINED NOT NULL DEFAULT 'passport'::document_type,
  original_file_name text NOT NULL,
  display_name text NOT NULL,
  CONSTRAINT documents_pkey PRIMARY KEY (id),
  CONSTRAINT documents_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  price numeric NOT NULL DEFAULT 0.00,
  currency text DEFAULT 'BDT'::text,
  interval_unit text NOT NULL DEFAULT 'monthly'::text,
  max_candidates integer,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT plans_pkey PRIMARY KEY (id)
);
CREATE TABLE public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  plan_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['ACTIVE'::text, 'PAST_DUE'::text, 'EXPIRED'::text, 'CANCELLED'::text, 'TRIALING'::text])),
  current_period_start timestamp with time zone NOT NULL DEFAULT now(),
  current_period_end timestamp with time zone NOT NULL,
  cancel_at_period_end boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  next_billing_at timestamp with time zone,
  trial_ends_at timestamp with time zone,
  billing_anchor timestamp with time zone,
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT subscriptions_tenant_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id),
  CONSTRAINT subscriptions_plan_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id)
);
CREATE TABLE public.invoices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  subscription_id uuid,
  invoice_number text NOT NULL UNIQUE,
  amount numeric NOT NULL DEFAULT 0.00,
  currency text NOT NULL DEFAULT 'BDT'::text,
  status text NOT NULL DEFAULT 'PAID'::text CHECK (status = ANY (ARRAY['PAID'::text, 'PENDING'::text, 'VOID'::text, 'REFUNDED'::text])),
  payment_method text,
  transaction_id text,
  receipt_url text,
  paid_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT invoices_pkey PRIMARY KEY (id),
  CONSTRAINT invoices_tenant_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id),
  CONSTRAINT invoices_subscription_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id)
);
CREATE TABLE public.system_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  user_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  type text DEFAULT 'INFO'::text CHECK (type = ANY (ARRAY['INFO'::text, 'WARNING'::text, 'ALERT'::text, 'BILLING'::text])),
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT system_notifications_pkey PRIMARY KEY (id)
);
CREATE TABLE public.reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  report_type text NOT NULL,
  file_format text NOT NULL DEFAULT 'pdf'::text,
  storage_path text NOT NULL,
  file_url text NOT NULL,
  file_size_mb numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reports_pkey PRIMARY KEY (id)
);
CREATE TABLE public.settings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  tenant_id uuid NOT NULL UNIQUE,
  company_name text NOT NULL,
  company_logo text,
  timezone text NOT NULL DEFAULT 'Asia/Dhaka'::text,
  language text NOT NULL DEFAULT 'en'::text,
  currency text NOT NULL DEFAULT 'BDT'::text,
  date_format text NOT NULL DEFAULT 'DD-MM-YYYY'::text,
  time_format text NOT NULL DEFAULT '24h'::text,
  default_candidate_status text NOT NULL DEFAULT 'NEW'::text,
  medical_expiry_warning_days integer NOT NULL DEFAULT 30,
  visa_expiry_warning_days integer NOT NULL DEFAULT 30,
  in_app_notifications boolean NOT NULL DEFAULT true,
  email_notifications boolean NOT NULL DEFAULT true,
  session_timeout_minutes integer NOT NULL DEFAULT 30,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT settings_pkey PRIMARY KEY (id),
  CONSTRAINT settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id)
);
CREATE TABLE public.tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  candidate_id uuid,
  assigned_to uuid,
  title text NOT NULL,
  description text,
  priority text NOT NULL DEFAULT 'MEDIUM'::text CHECK (priority = ANY (ARRAY['LOW'::text, 'MEDIUM'::text, 'HIGH'::text, 'URGENT'::text])),
  status text NOT NULL DEFAULT 'TODO'::text CHECK (status = ANY (ARRAY['TODO'::text, 'IN_PROGRESS'::text, 'DONE'::text, 'CANCELLED'::text])),
  due_date timestamp with time zone,
  completed_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tasks_pkey PRIMARY KEY (id),
  CONSTRAINT tasks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id),
  CONSTRAINT tasks_candidate_id_fkey FOREIGN KEY (candidate_id) REFERENCES public.candidates(id),
  CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id),
  CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.version_releases (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  version_number character varying NOT NULL UNIQUE,
  name character varying NOT NULL,
  release_type USER-DEFINED NOT NULL DEFAULT 'MINOR'::release_type,
  status USER-DEFINED NOT NULL DEFAULT 'PLANNED'::release_status,
  planning_started_at date,
  planning_completed_at date,
  release_date date,
  description text,
  changes_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT version_releases_pkey PRIMARY KEY (id)
);