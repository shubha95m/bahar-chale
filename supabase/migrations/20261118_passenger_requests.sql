-- Migration: 20261118_passenger_requests.sql
-- Passenger Itineraries & Travel Requests

CREATE TABLE IF NOT EXISTS public.passenger_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    origin_city TEXT NOT NULL,
    origin_area TEXT,
    destination_city TEXT NOT NULL,
    destination_area TEXT,
    travel_date DATE NOT NULL,
    travel_time TIME,
    is_time_flexible BOOLEAN DEFAULT true NOT NULL,
    seats_needed INTEGER DEFAULT 1 NOT NULL,
    preferred_vehicle TEXT DEFAULT 'any' CHECK (preferred_vehicle IN ('any', 'car', 'bike')),
    contribution_budget NUMERIC(10,2),
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'matched', 'cancelled', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_passenger_requests_origin ON public.passenger_requests (LOWER(origin_city));
CREATE INDEX IF NOT EXISTS idx_passenger_requests_dest ON public.passenger_requests (LOWER(destination_city));
CREATE INDEX IF NOT EXISTS idx_passenger_requests_date ON public.passenger_requests (travel_date);
CREATE INDEX IF NOT EXISTS idx_passenger_requests_status ON public.passenger_requests (status);
CREATE INDEX IF NOT EXISTS idx_passenger_requests_requester ON public.passenger_requests (requester_id);

ALTER TABLE public.passenger_requests ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'passenger_requests' AND policyname = 'Anyone can view open passenger requests'
    ) THEN
        CREATE POLICY "Anyone can view open passenger requests" ON public.passenger_requests
            FOR SELECT TO public USING (true);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'passenger_requests' AND policyname = 'Users can create their own passenger requests'
    ) THEN
        CREATE POLICY "Users can create their own passenger requests" ON public.passenger_requests
            FOR INSERT TO authenticated WITH CHECK (auth.uid() = requester_id);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'passenger_requests' AND policyname = 'Users can update their own passenger requests'
    ) THEN
        CREATE POLICY "Users can update their own passenger requests" ON public.passenger_requests
            FOR UPDATE TO authenticated USING (auth.uid() = requester_id);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'passenger_requests' AND policyname = 'Users can delete their own passenger requests'
    ) THEN
        CREATE POLICY "Users can delete their own passenger requests" ON public.passenger_requests
            FOR DELETE TO authenticated USING (auth.uid() = requester_id);
    END IF;
END $$;
