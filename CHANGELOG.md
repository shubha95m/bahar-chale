# Changelog

All notable changes to the Bahar Chale project will be documented in this file.

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
