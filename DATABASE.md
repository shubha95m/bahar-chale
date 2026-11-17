# Bahar Chale — Database Specification & Schema Reference

**Database:** PostgreSQL 17 (Supabase Hosted)  
**Project ID:** `iswbhvtosueavuzavtbr`  
**Region:** `ap-south-1` (Mumbai, India)  
**RLS Status:** Enabled on 100% of public tables  

---

## 1. Cloud Tables (Supabase PostgreSQL)

### 1. `public.profiles`
Stores user profile information created automatically via Auth trigger on user registration.
- `id` (UUID, PK, references `auth.users(id) ON DELETE CASCADE`)
- `display_name` (TEXT, NOT NULL)
- `email` (TEXT)
- `avatar_url` (TEXT)
- `phone_number` (TEXT, nullable)
- `phone_verified` (BOOLEAN, DEFAULT false)
- `home_city` (TEXT, nullable)
- `preferred_language` (TEXT, DEFAULT 'hi')
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 2. `public.rides`
Available rides offered by drivers or general travelers coordinating journeys.
- `id` (UUID, PK, DEFAULT `gen_random_uuid()`)
- `owner_id` (UUID, NOT NULL, references `auth.users(id)`)
- `ride_category` (`private_vehicle` | `general_travel`)
- `vehicle_type` (TEXT, e.g. `car`, `bike`, `other`)
- `origin_city` (TEXT, NOT NULL, indexed lowercase)
- `origin_area` (TEXT, optional)
- `origin_latitude`, `origin_longitude` (DOUBLE PRECISION, optional)
- `destination_city` (TEXT, NOT NULL, indexed lowercase)
- `destination_area` (TEXT, optional)
- `destination_latitude`, `destination_longitude` (DOUBLE PRECISION, optional)
- `travel_date` (DATE, NOT NULL, indexed)
- `travel_time` (TIME, optional)
- `is_time_flexible` (BOOLEAN, DEFAULT true)
- `total_seats` (INTEGER, DEFAULT 1)
- `available_seats` (INTEGER, DEFAULT 1)
- `contribution_amount` (NUMERIC(10,2), optional)
- `notes` (TEXT, optional)
- `status` (`draft` | `open` | `full` | `cancelled` | `completed`, indexed)
- `created_at`, `updated_at` (TIMESTAMPTZ)

### 3. `public.ride_requests`
Requests submitted by passengers to join a ride.
- `id` (UUID, PK)
- `ride_id` (UUID, references `public.rides(id)`)
- `requester_id` (UUID, references `auth.users(id)`)
- `seats_requested` (INTEGER, DEFAULT 1)
- `status` (`pending` | `accepted` | `rejected` | `cancelled`)
- `message` (TEXT, optional)
- **Constraint:** `UNIQUE (ride_id, requester_id)` (prevents duplicate requests)

### 4. `public.ride_agreements`
Mutual travel agreement created upon request acceptance.
- `id` (UUID, PK)
- `ride_request_id` (UUID, UNIQUE, references `public.ride_requests(id)`)
- `pickup_details` (TEXT, NOT NULL)
- `drop_details` (TEXT, NOT NULL)
- `agreed_date` (DATE, NOT NULL)
- `agreed_time` (TIME, optional)
- `agreed_contribution` (NUMERIC(10,2), optional)
- `owner_confirmed` (BOOLEAN, DEFAULT false)
- `requester_confirmed` (BOOLEAN, DEFAULT false)
- `status` (`draft` | `confirmed` | `cancelled` | `completed`)

### 5. `public.ride_messages`
Realtime in-app private chat between ride owner and requester.
- `id` (UUID, PK)
- `ride_request_id` (UUID, references `public.ride_requests(id)`)
- `sender_id` (UUID, references `auth.users(id)`)
- `message_body` (TEXT, NOT NULL)
- `created_at` (TIMESTAMPTZ, indexed)
- `read_at` (TIMESTAMPTZ, nullable)

### 6. `public.user_blocks` & `public.user_reports`
Safety & privacy infrastructure.
- `user_blocks`: `(blocker_id, blocked_id)`
- `user_reports`: `(reporter_id, reported_user_id, ride_id, reason, description, status)`

### 7. `public.notifications`
In-app notification records for request updates, acceptances, and messages.

---

## 2. Atomic Stored Procedures (RPC)

### `public.accept_ride_request(p_request_id UUID)`
- Locks `ride_requests` and `rides` row using `FOR UPDATE`.
- Checks: requester eligibility, request status is `pending`, and `available_seats >= seats_requested`.
- Atomically decrements `available_seats`, transitioning ride to `full` if seats hit 0.
- Marks request `accepted`.
- Inserts or updates corresponding `ride_agreements` record in `draft` state.
- Dispatches in-app notification to requester.

### `public.confirm_agreement(p_agreement_id UUID)`
- Validates caller is either ride owner or requester.
- Sets caller's confirmation flag (`owner_confirmed` or `requester_confirmed`).
- If both flags are `true`, atomically transitions status to `confirmed`.

---

## 3. Local SQLite Schema (Offline Cache & Sync)

Located at `<app_documents>/bahar_chale_cache.db`:
- `local_cached_rides`: Fast offline search & view history.
- `local_cached_agreements`: Cached confirmed arrangements for travelers on the road.
- `local_sync_outbox`: Idempotent mutations queued when device connectivity drops.
