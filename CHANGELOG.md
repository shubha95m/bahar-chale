# Changelog

All notable changes to the Bahar Chale project will be documented in this file.

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
