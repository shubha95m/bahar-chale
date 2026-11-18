-- Migration: Legal Terms, Privacy Policy & User Consent Audit Log (India Compliance)
-- IT Act 2000 (Section 10A), DPDP Act 2023 & Motor Vehicles Act Peer-to-Peer Ridesharing Exemption

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS terms_accepted BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ DEFAULT now(),
ADD COLUMN IF NOT EXISTS terms_version TEXT DEFAULT 'v1.0-2026',
ADD COLUMN IF NOT EXISTS terms_consent_text TEXT;

CREATE TABLE IF NOT EXISTS public.user_consent_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    consent_type TEXT NOT NULL DEFAULT 'TERMS_AND_PRIVACY',
    terms_version TEXT NOT NULL DEFAULT 'v1.0-2026',
    consent_statement TEXT NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.user_consent_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'user_consent_logs' AND policyname = 'Users can read own consent logs'
    ) THEN
        CREATE POLICY "Users can read own consent logs" ON public.user_consent_logs
            FOR SELECT TO authenticated
            USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'user_consent_logs' AND policyname = 'Users can insert own consent logs'
    ) THEN
        CREATE POLICY "Users can insert own consent logs" ON public.user_consent_logs
            FOR INSERT TO authenticated
            WITH CHECK (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'user_consent_logs' AND policyname = 'Service role full access on user_consent_logs'
    ) THEN
        CREATE POLICY "Service role full access on user_consent_logs" ON public.user_consent_logs
            FOR ALL TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;
