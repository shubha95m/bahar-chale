# Changelog

All notable changes to the Bahar Chale project will be documented in this file.

## [0.3.0] - 2026-11-17
### Added
- **Milestone 4 (Mutual Agreements & Verification):**
  - Created `RideAgreement` entity and `AgreementRepository`.
  - Implemented `AgreementPage` (`/agreement/:id`) with real-time mutual acceptance UI.
  - Deployed and verified Supabase Postgres RPC `confirm_agreement` with auto-transition to `confirmed` status when both driver and rider have accepted.
  - Linked agreement verification flow directly into `RideDetailsPage` and `MyTravelPage`.
- **Milestone 5 (Real-time Messaging & Home Experience):**
  - Created `ChatMessage` entity and `ChatRepository` powered by Supabase Realtime Channel subscriptions.
  - Implemented `ChatPage` (`/chat/:id`) with message bubbles, time formatting, and live message broadcasting.
  - Upgraded `HomePage` with live dynamic feeds:
    - Upcoming journeys card with one-click agreement / chat shortcuts.
    - Pending requests banner for drivers with instant accept/reject shortcuts.
    - Recently posted community rides list.
  - Implemented `ProfilePage` (`/profile`) with live role toggling (Driver ↔ Rider), active security badges, and clean session logout.
- **Local Sandbox & SPA Routing:**
  - Added dedicated 1-click bypass login buttons on `LoginPage` for instant local testing of Driver and Rider personas.
  - Resolved GoTrue token null-scan issue in Supabase Auth.
  - Created `scripts/serve_spa.py` with full Single Page Application fallback routing on port 8085.
- **Automated Tests:**
  - Added unit test suites for `RideAgreement` and `ChatMessage`.
  - Verified 11/11 automated tests passing with zero analyzer warnings.

## [0.2.0] - 2026-11-17
### Added
- **Milestone 2 (Ride Management):**
  - Implemented `CreateRidePage` with category switching (Private Vehicle Car/Bike vs General Travel), seat counters, date/time pickers, and contribution amount inputs.
  - Implemented `RidesRepository` with normalized city matching, pagination, and local SQLite caching.
  - Implemented `MyTravelPage` with dual tabs for offered rides and submitted requests with real-time status badges.
- **Milestone 3 (Ride Matching & Request Workflow):**
  - Implemented `SearchRidesPage` with city-to-city matching, travel date filtering, and responsive result cards.
  - Implemented `RideDetailsPage` showing route summary, provider info, seats remaining, and incoming requests.
  - Atomic seat allocation and request approval calling Supabase RPC `accept_ride_request`.
  - Rejection and cancellation workflows for ride requests.
- **Google Maps Integration:**
  - Integrated zero-cost Google Maps deep linking (`MapLauncher`) for route navigation on Android and Web.
- **Automated Tests:**
  - Added unit test suites for `Ride`, `RideRequest`, and `SearchParams` normalization.
  - Added widget tests for `CreateRidePage` and `SearchRidesPage`.

## [0.1.0] - 2026-11-17
### Added
- Initialized Bahar Chale project with Flutter (Android & Web) architecture.
- Established clean architecture with Riverpod, GoRouter, Supabase, and SQLite caching.
- Created dedicated Supabase project `bahar-chale` in region `ap-south-1` (`iswbhvtosueavuzavtbr`).
- Applied database migration with 8 tables (`profiles`, `rides`, `ride_requests`, `ride_agreements`, `ride_messages`, `user_blocks`, `user_reports`, `notifications`).
- Enabled Row Level Security on all public tables with zero-trust access policies.
- Deployed atomic RPC procedures for `accept_ride_request` and `confirm_agreement`.
- Set up Supabase Realtime publication on chat messages, requests, and agreements.
- Linked Git repository to GitHub: `shubha95m/bahar-chale`.
- Created technical documentation suite (`ARCHITECTURE.md`, `DATABASE.md`, `SECURITY.md`, `DEPLOYMENT.md`, `TESTING.md`).
