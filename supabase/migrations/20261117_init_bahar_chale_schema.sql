-- Bahar Chale - Initial Schema Migration
-- Migration: 20261117_init_bahar_chale_schema.sql

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    email TEXT,
    avatar_url TEXT,
    phone_number TEXT,
    phone_verified BOOLEAN DEFAULT false,
    home_city TEXT,
    preferred_language TEXT DEFAULT 'hi',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Profiles trigger for new auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, email, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1), 'यात्री'),
        NEW.email,
        NEW.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Revoke public execution from handle_new_user
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

-- 2. Rides Table
CREATE TABLE IF NOT EXISTS public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ride_category TEXT NOT NULL CHECK (ride_category IN ('private_vehicle', 'general_travel')),
    vehicle_type TEXT,
    origin_city TEXT NOT NULL,
    origin_area TEXT,
    origin_latitude DOUBLE PRECISION,
    origin_longitude DOUBLE PRECISION,
    origin_place_id TEXT,
    destination_city TEXT NOT NULL,
    destination_area TEXT,
    destination_latitude DOUBLE PRECISION,
    destination_longitude DOUBLE PRECISION,
    destination_place_id TEXT,
    travel_date DATE NOT NULL,
    travel_time TIME,
    is_time_flexible BOOLEAN DEFAULT true NOT NULL,
    total_seats INTEGER DEFAULT 1 NOT NULL,
    available_seats INTEGER DEFAULT 1 NOT NULL,
    contribution_amount NUMERIC(10,2),
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('draft', 'open', 'full', 'cancelled', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_rides_origin_city ON public.rides (LOWER(origin_city));
CREATE INDEX IF NOT EXISTS idx_rides_destination_city ON public.rides (LOWER(destination_city));
CREATE INDEX IF NOT EXISTS idx_rides_travel_date ON public.rides (travel_date);
CREATE INDEX IF NOT EXISTS idx_rides_status ON public.rides (status);
CREATE INDEX IF NOT EXISTS idx_rides_owner_id ON public.rides (owner_id);

-- 3. Ride Requests Table
CREATE TABLE IF NOT EXISTS public.ride_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
    requester_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    seats_requested INTEGER DEFAULT 1 NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT unique_ride_requester UNIQUE (ride_id, requester_id)
);

CREATE INDEX IF NOT EXISTS idx_ride_requests_ride ON public.ride_requests (ride_id);
CREATE INDEX IF NOT EXISTS idx_ride_requests_requester ON public.ride_requests (requester_id);

-- 4. Ride Agreements Table
CREATE TABLE IF NOT EXISTS public.ride_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_request_id UUID NOT NULL UNIQUE REFERENCES public.ride_requests(id) ON DELETE CASCADE,
    pickup_details TEXT NOT NULL,
    drop_details TEXT NOT NULL,
    agreed_date DATE NOT NULL,
    agreed_time TIME,
    agreed_contribution NUMERIC(10,2),
    owner_confirmed BOOLEAN DEFAULT false NOT NULL,
    requester_confirmed BOOLEAN DEFAULT false NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'confirmed', 'cancelled', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 5. Ride Messages Table (Chat)
CREATE TABLE IF NOT EXISTS public.ride_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_request_id UUID NOT NULL REFERENCES public.ride_requests(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message_body TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_ride_messages_request ON public.ride_messages (ride_request_id, created_at);
CREATE INDEX IF NOT EXISTS idx_ride_messages_sender_id ON public.ride_messages (sender_id);

-- 6. User Blocks Table
CREATE TABLE IF NOT EXISTS public.user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT unique_blocker_blocked UNIQUE (blocker_id, blocked_id)
);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked_id ON public.user_blocks (blocked_id);

-- 7. User Reports Table
CREATE TABLE IF NOT EXISTS public.user_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    ride_id UUID REFERENCES public.rides(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_reports_reporter_id ON public.user_reports (reporter_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_reported_user_id ON public.user_reports (reported_user_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_ride_id ON public.user_reports (ride_id);

-- 8. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_type TEXT NOT NULL,
    reference_id TEXT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON public.notifications (recipient_id, created_at DESC);

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Role grants
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON public.rides TO anon;

-- Profiles Policies
CREATE POLICY "Profiles readable by authenticated users"
ON public.profiles FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = id)
WITH CHECK ((SELECT auth.uid()) = id);

-- Rides Policies
CREATE POLICY "Public discovery for open rides"
ON public.rides FOR SELECT
TO anon, authenticated
USING (status IN ('open', 'full', 'completed'));

CREATE POLICY "Owners can view own rides in any status"
ON public.rides FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = owner_id);

CREATE POLICY "Owners can insert rides"
ON public.rides FOR INSERT
TO authenticated
WITH CHECK ((SELECT auth.uid()) = owner_id);

CREATE POLICY "Owners can update own rides"
ON public.rides FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = owner_id)
WITH CHECK ((SELECT auth.uid()) = owner_id);

-- Ride Requests Policies
CREATE POLICY "Requesters and owners can view requests"
ON public.ride_requests FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = requester_id
    OR (SELECT auth.uid()) IN (SELECT owner_id FROM public.rides WHERE id = ride_id)
);

CREATE POLICY "Requesters can create requests"
ON public.ride_requests FOR INSERT
TO authenticated
WITH CHECK (
    (SELECT auth.uid()) = requester_id
    AND (SELECT auth.uid()) NOT IN (SELECT owner_id FROM public.rides WHERE id = ride_id)
);

CREATE POLICY "Requesters can update their own request or owners can update"
ON public.ride_requests FOR UPDATE
TO authenticated
USING (
    (SELECT auth.uid()) = requester_id
    OR (SELECT auth.uid()) IN (SELECT owner_id FROM public.rides WHERE id = ride_id)
)
WITH CHECK (
    (SELECT auth.uid()) = requester_id
    OR (SELECT auth.uid()) IN (SELECT owner_id FROM public.rides WHERE id = ride_id)
);

-- Ride Agreements Policies
CREATE POLICY "Participants can view agreement"
ON public.ride_agreements FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.ride_requests rr
        JOIN public.rides r ON r.id = rr.ride_id
        WHERE rr.id = ride_request_id
        AND ((SELECT auth.uid()) = rr.requester_id OR (SELECT auth.uid()) = r.owner_id)
    )
);

CREATE POLICY "Participants can update agreement"
ON public.ride_agreements FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.ride_requests rr
        JOIN public.rides r ON r.id = rr.ride_id
        WHERE rr.id = ride_request_id
        AND ((SELECT auth.uid()) = rr.requester_id OR (SELECT auth.uid()) = r.owner_id)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.ride_requests rr
        JOIN public.rides r ON r.id = rr.ride_id
        WHERE rr.id = ride_request_id
        AND ((SELECT auth.uid()) = rr.requester_id OR (SELECT auth.uid()) = r.owner_id)
    )
);

-- Ride Messages Policies
CREATE POLICY "Conversation participants can read messages"
ON public.ride_messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.ride_requests rr
        JOIN public.rides r ON r.id = rr.ride_id
        WHERE rr.id = ride_request_id
        AND ((SELECT auth.uid()) = rr.requester_id OR (SELECT auth.uid()) = r.owner_id)
    )
);

CREATE POLICY "Conversation participants can send messages"
ON public.ride_messages FOR INSERT
TO authenticated
WITH CHECK (
    (SELECT auth.uid()) = sender_id
    AND EXISTS (
        SELECT 1 FROM public.ride_requests rr
        JOIN public.rides r ON r.id = rr.ride_id
        WHERE rr.id = ride_request_id
        AND ((SELECT auth.uid()) = rr.requester_id OR (SELECT auth.uid()) = r.owner_id)
    )
);

-- User Blocks Policies
CREATE POLICY "Users can manage own blocks"
ON public.user_blocks FOR ALL
TO authenticated
USING ((SELECT auth.uid()) = blocker_id)
WITH CHECK ((SELECT auth.uid()) = blocker_id);

-- User Reports Policies
CREATE POLICY "Users can insert reports"
ON public.user_reports FOR INSERT
TO authenticated
WITH CHECK ((SELECT auth.uid()) = reporter_id);

CREATE POLICY "Users can view own submitted reports"
ON public.user_reports FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = reporter_id);

-- Notifications Policies
CREATE POLICY "Users can view and update own notifications"
ON public.notifications FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = recipient_id);

CREATE POLICY "Users can mark own notifications read"
ON public.notifications FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = recipient_id)
WITH CHECK ((SELECT auth.uid()) = recipient_id);

-- Atomic RPC Functions for Transactional operations
CREATE OR REPLACE FUNCTION public.accept_ride_request(p_request_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_req RECORD;
    v_ride RECORD;
    v_current_user_id UUID;
    v_agreement_id UUID;
BEGIN
    v_current_user_id := auth.uid();
    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Fetch request
    SELECT * INTO v_req FROM public.ride_requests WHERE id = p_request_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Request not found');
    END IF;

    IF v_req.status != 'pending' THEN
        RETURN jsonb_build_object('success', false, 'error', 'Request is not pending');
    END IF;

    -- Fetch and lock ride
    SELECT * INTO v_ride FROM public.rides WHERE id = v_req.ride_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Ride not found');
    END IF;

    IF v_ride.owner_id != v_current_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Only ride owner can accept request');
    END IF;

    IF v_ride.available_seats < v_req.seats_requested THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not enough available seats');
    END IF;

    -- Decrement available seats atomically
    UPDATE public.rides
    SET available_seats = available_seats - v_req.seats_requested,
        status = CASE WHEN (available_seats - v_req.seats_requested) = 0 THEN 'full' ELSE status END,
        updated_at = now()
    WHERE id = v_ride.id;

    -- Update request status
    UPDATE public.ride_requests
    SET status = 'accepted',
        updated_at = now()
    WHERE id = p_request_id;

    -- Create or get agreement
    INSERT INTO public.ride_agreements (
        ride_request_id,
        pickup_details,
        drop_details,
        agreed_date,
        agreed_time,
        agreed_contribution,
        owner_confirmed,
        requester_confirmed,
        status
    ) VALUES (
        p_request_id,
        COALESCE(v_ride.origin_area, v_ride.origin_city),
        COALESCE(v_ride.destination_area, v_ride.destination_city),
        v_ride.travel_date,
        v_ride.travel_time,
        v_ride.contribution_amount,
        false,
        false,
        'draft'
    )
    ON CONFLICT (ride_request_id) DO UPDATE SET updated_at = now()
    RETURNING id INTO v_agreement_id;

    -- Notification to requester
    INSERT INTO public.notifications (
        recipient_id,
        notification_type,
        reference_id,
        title,
        body
    ) VALUES (
        v_req.requester_id,
        'request_accepted',
        p_request_id::TEXT,
        'सवारी अनुरोध स्वीकृत!',
        'आपका यात्रा अनुरोध स्वीकार कर लिया गया है। विवरण साझा करें।'
    );

    RETURN jsonb_build_object('success', true, 'agreement_id', v_agreement_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.confirm_agreement(p_agreement_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_agr RECORD;
    v_req RECORD;
    v_ride RECORD;
    v_current_user_id UUID;
    v_is_owner BOOLEAN;
    v_is_requester BOOLEAN;
    v_new_owner_confirmed BOOLEAN;
    v_new_requester_confirmed BOOLEAN;
BEGIN
    v_current_user_id := auth.uid();
    IF v_current_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    SELECT * INTO v_agr FROM public.ride_agreements WHERE id = p_agreement_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Agreement not found');
    END IF;

    SELECT * INTO v_req FROM public.ride_requests WHERE id = v_agr.ride_request_id;
    SELECT * INTO v_ride FROM public.rides WHERE id = v_req.ride_id;

    v_is_owner := (v_ride.owner_id = v_current_user_id);
    v_is_requester := (v_req.requester_id = v_current_user_id);

    IF NOT (v_is_owner OR v_is_requester) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authorized to confirm this agreement');
    END IF;

    v_new_owner_confirmed := CASE WHEN v_is_owner THEN true ELSE v_agr.owner_confirmed END;
    v_new_requester_confirmed := CASE WHEN v_is_requester THEN true ELSE v_agr.requester_confirmed END;

    UPDATE public.ride_agreements
    SET owner_confirmed = v_new_owner_confirmed,
        requester_confirmed = v_new_requester_confirmed,
        status = CASE WHEN (v_new_owner_confirmed AND v_new_requester_confirmed) THEN 'confirmed' ELSE status END,
        updated_at = now()
    WHERE id = p_agreement_id;

    RETURN jsonb_build_object(
        'success', true,
        'status', CASE WHEN (v_new_owner_confirmed AND v_new_requester_confirmed) THEN 'confirmed' ELSE 'pending_partner' END
    );
END;
$$;

-- Revoke anon execution on RPCs
REVOKE EXECUTE ON FUNCTION public.accept_ride_request(UUID) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.confirm_agreement(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.accept_ride_request(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirm_agreement(UUID) TO authenticated;

-- Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.ride_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ride_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ride_agreements;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
