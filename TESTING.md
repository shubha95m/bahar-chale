# Bahar Chale — Automated Testing & Verification Guide

## Test Suite Overview

### 1. Unit Tests (`test/unit/`)
- `ride_test.dart`:
  - City normalization and whitespace stripping for query equivalence.
  - Route display formatting (`originArea, originCity -> destArea, destCity`).
  - Serialization / deserialization round-trip integrity for `Ride` model.
- `request_test.dart`:
  - Deserialization and parsing of `RideRequest` including relational join with `profiles`.
  - Seat count parsing and status enum mapping.
- `agreement_test.dart`:
  - `RideAgreement.isFullyConfirmed` status checks (requires both driver and rider confirmation).
  - Round-trip serialization and field validation.
- `chat_test.dart`:
  - `ChatMessage` model parsing with sender profile joining.
  - Serialization to Supabase schema payload.

### 2. Widget Tests (`test/widget/`)
- `create_ride_widget_test.dart`:
  - Category toggles (Private Vehicle Car/Bike vs General Travel).
  - Form field rendering and validation.
- `search_rides_widget_test.dart`:
  - Search input fields (Origin city, Destination city).
  - Empty search results state.

### 3. Database & Security Verification
- 100% RLS on all 8 tables: `profiles`, `rides`, `ride_requests`, `ride_agreements`, `ride_messages`, `user_blocks`, `user_reports`, `notifications`.
- Atomic RPC procedures `accept_ride_request` and `confirm_agreement` executing under Postgres transactions.
- Supabase Realtime publication active on `ride_messages`, `ride_requests`, and `ride_agreements`.

## Running Automated Tests
```bash
flutter test
flutter analyze
```

## Local End-to-End Testing (Pilot / Demo Mode)
The application includes pre-configured local demo credentials to test the complete lifecycle without requiring third-party Google OAuth credentials:

1. **Start the local SPA server:**
   ```bash
   python3 scripts/serve_spa.py build/web
   ```
   Open `http://localhost:8085` in your browser.

2. **Login as Driver (राहुल शर्मा):**
   - Click **"⚡ डेमो मोड: चालक (Driver) के रूप में प्रवेश"**
   - Go to **"सवारी ऑफर करें"** (Offer Ride)
   - Fill in: Origin (e.g., Pune), Destination (e.g., Mumbai), Seats (3), Date & Time
   - Click **"सवारी पोस्ट करें"** -> Successfully creates ride.

3. **Login as Rider (अमित कुमार) in an Incognito / Second Tab:**
   - Click **"👥 डेमो मोड: यात्री (Rider) के रूप में प्रवेश"**
   - Go to **"सवारी खोजें"** (Find Ride)
   - Search for Origin "Pune" and Destination "Mumbai"
   - Select the published ride -> Click **"सवारी का अनुरोध भेजें"** (Request Ride) -> Select 1 seat.

4. **Driver Accepts Request & Mutually Confirms Agreement:**
   - In Driver window, view Home dashboard alert or My Travel tab.
   - Click **"स्वीकार करें"** (Accept) -> Triggers atomic `accept_ride_request` RPC.
   - Once accepted, click **"सहमति देखें"** (View Agreement) -> Click **"सहमति की पुष्टि करें"** (Confirm).
   - In Rider window, also click **"सहमति की पुष्टि करें"** -> Agreement status transitions to `confirmed`.

5. **Real-time Chatting:**
   - Both driver and rider can click **"संदेश भेजें"** (Open Chat) to exchange instantaneous coordinates and messages via Supabase Realtime channels.
