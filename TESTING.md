# Bahar Chale — Automated Testing & Verification Guide

## Test Suite Overview

1. **Unit Tests (`test/unit/`):**
   - City normalization and search matching.
   - Date validation and ride state transitions.
   - Atomic seat calculation and overbooking prevention logic.
   - Repository error handling and offline outbox queuing.

2. **Widget Tests (`test/widget/`):**
   - Hindi localization rendering and typography check.
   - Home screen quick actions ("मुझे यात्रा करनी है" & "मैं साथ ले जा सकता हूँ").
   - Ride creation form validation.
   - Request and confirmation UI states.

3. **Database & Security Tests:**
   - Verify RLS policies on `rides`, `ride_requests`, `ride_agreements`, and `ride_messages`.
   - Verify `accept_ride_request` and `confirm_agreement` RPC functions enforce authentication and seat limits.

## Running Tests
```bash
flutter test
```
