# Bahar Chale (बाहर चलें)

> **सफर साथ में, आसान हर राह।**  
> Lightweight community ride-sharing & journey coordination platform for Android and Web.

---

## Highlights

- **Lightweight & Clean:** No commercial cab commissions, no payment gateways, no meters, no bloated analytics dashboards.
- **₹0/Month Infrastructure Target:** Built entirely using free-tier services (Supabase Free, Cloudflare Pages Free, Google Maps deep link intents).
- **Hindi-First Interface:** Intuitive, friendly UI designed for quick readability and high touch targets on mobile devices.
- **Offline-Ready:** Dual-layer architecture with Supabase Cloud Postgres as source of truth and local SQLite cache with an idempotent sync outbox.
- **Privacy & Security First:** 100% RLS enforcement, atomic seat allocation, and mutual agreement confirmation before travel.

---

## Tech Stack

- **Frontend:** Flutter 3.50+ / Dart 3.14+ (Material 3)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Routing:** GoRouter (`go_router`)
- **Backend / DB:** Supabase PostgreSQL (`ap-south-1` Mumbai)
- **Realtime:** Supabase Realtime WebSocket engine
- **Local Cache:** SQLite (`sqflite` / `sqflite_common_ffi`)
- **Maps:** Google Maps URL intents (Zero API cost)
- **Auth:** Google Sign-In with Supabase Auth token exchange

---

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/shubha95m/bahar-chale.git
   cd bahar-chale
   ```
2. Configure environment credentials in `.env`:
   ```bash
   cp .env.example .env
   # Add your SUPABASE_URL and SUPABASE_ANON_KEY
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run locally:
   ```bash
   flutter run -d chrome
   # or on an Android device:
   flutter run -d <device_id>
   ```

---

## Documentation

- [Architecture Blueprint](ARCHITECTURE.md)
- [Database Schema & Stored Procedures](DATABASE.md)
- [Security & Privacy](SECURITY.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Automated Testing](TESTING.md)
- [Changelog](CHANGELOG.md)
