CREATE TYPE auth.aal_level AS ENUM ('aal1', 'aal2', 'aal3');

CREATE TYPE auth.code_challenge_method AS ENUM ('s256', 'plain');

CREATE TYPE auth.factor_status AS ENUM ('unverified', 'verified');

CREATE TYPE auth.factor_type AS ENUM ('totp', 'webauthn', 'phone');

CREATE TYPE auth.oauth_authorization_status AS ENUM ('pending', 'approved', 'denied', 'expired');

CREATE TYPE auth.oauth_client_type AS ENUM ('public', 'confidential');

CREATE TYPE auth.oauth_registration_type AS ENUM ('dynamic', 'manual');

CREATE TYPE auth.oauth_response_type AS ENUM ('code');

CREATE TYPE auth.one_time_token_type AS ENUM ('confirmation_token', 'reauthentication_token', 'recovery_token', 'email_change_token_new', 'email_change_token_current', 'phone_change_token');

CREATE TYPE public.candidate_country AS ENUM ('KSA', 'FIJI', 'BELARUS', 'MAURITIUS', 'LAOS');

CREATE TYPE public.candidate_stage AS ENUM ('RECEIVED', 'MEDICAL', 'MOFA', 'FINGER', 'POLICE_CLEARANCE', 'VISA', 'MANPOWER', 'FLIGHT', 'COMPLETED', 'RETURNED', 'CANCELLED');

CREATE TYPE public.country AS ENUM ('KS', 'FIJI', 'MARITUS', 'LOUS');

CREATE TYPE public.document_type AS ENUM ('passport', 'visa');

CREATE TYPE public.mofa_pipeline_status AS ENUM ('MOFA_DONE', 'EXPIRED_FLOW', 'INVALID_MOFA', 'MOFA_RENEWED', 'USED_IN_VISA');

CREATE TYPE public.release_status AS ENUM ('PLANNED', 'IN_PROGRESS', 'RELEASED', 'CANCELLED');

CREATE TYPE public.release_type AS ENUM ('MAJOR', 'MINOR', 'PATCH');

CREATE TYPE realtime.action AS ENUM ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'ERROR');

CREATE TYPE realtime.equality_op AS ENUM ('eq', 'neq', 'lt', 'lte', 'gt', 'gte', 'in', 'like', 'ilike', 'is', 'match', 'imatch', 'isdistinct');

CREATE TYPE storage.buckettype AS ENUM ('STANDARD', 'ANALYTICS', 'VECTOR');