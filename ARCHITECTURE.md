# Bahar Chale (बाहर चलें) — Architecture Assessment & Blueprint

**Tagline:** सफर साथ में, आसान हर राह।  
**Target:** Android + Web  
**Infrastructure Budget:** ₹0/month (Free-tier architecture)

---

## 1. Architectural Strategy & Reuse

Bahar Chale follows the robust Clean Architecture patterns established in the sister application (`apna`):
- **Core State Management:** Riverpod (`flutter_riverpod`) for reactive dependency injection and view state.
- **Declarative Navigation:** GoRouter (`go_router`) supporting clean deep linking and browser URL handling.
- **Dual-Tier Data Architecture:**
  - **Cloud Truth:** Supabase PostgreSQL with strict Row Level Security (RLS) and Realtime WebSocket subscriptions.
  - **Local Persistence & Offline Cache:** SQLite (`sqflite` on mobile, `sqflite_common_ffi` on desktop/tests) backed by an idempotent Outbox Sync Manager for resilient offline operations.
- **Zero-Cost Maps Strategy:** Google Maps direct URL intent/web links (`url_launcher`) rather than metered Google Maps SDKs or Places APIs.

```
                      ┌────────────────────────────────────────┐
                      │          Flutter UI Layer              │
                      │  (Riverpod + GoRouter + Hindi Strings)  │
                      └──────────────────┬─────────────────────┘
                                         │
                      ┌──────────────────┴─────────────────────┐
                      │        Feature Domain & Repos          │
                      │    (Rides, Requests, Chat, Profile)    │
                      └─────────┬───────────────────┬──────────┘
                                │                   │
             ┌──────────────────┴──────┐    ┌───────┴─────────────────┐
             │     Sync Engine &       │    │  Supabase Client SDK    │
             │     Local SQLite Cache  │    │  (PostgREST + Realtime) │
             └─────────────────────────┘    └───────────┬─────────────┘
                                                        │
                                            ┌───────────┴─────────────┐
                                            │  Supabase Cloud (Postgres│
                                            │  RLS + RPC Transactions)│
                                            └─────────────────────────┘
```

---

## 2. Platform Scope

### A. Android (Mobile APK)
- Built for low-spec Android devices and weak mobile connectivity.
- Native Google Sign-In (`google_sign_in`) exchanging ID token with Supabase Auth (`signInWithIdToken`).
- Encrypted credential storage with `flutter_secure_storage`.
- Direct intent launcher to open Google Maps navigation for journey endpoints.

### B. Web (Cloudflare Pages)
- Responsive Flutter Web build for mobile and desktop browsers.
- Supabase Google OAuth with PKCE flow.
- Browser-safe session caching and SPA route restoration.

---

## 3. Directory & Module Structure

```
lib/
├── app/
│   ├── configuration/   # Environment config (.env), Supabase init
│   ├── router/          # GoRouter definitions & route guards
│   └── theme/           # Material 3 light/dark palette & Hindi typography
├── core/
│   ├── database/        # SQLite singleton & schema management
│   ├── errors/          # Unified failure models & Hindi error mappers
│   ├── localization/    # Hindi-first localization & string catalog
│   ├── sync/            # Transactional Sync Engine & outbox queue
│   └── utilities/       # Date/time formatting, URL launchers, validators
└── features/
    ├── authentication/  # Google Sign-In, Session monitor, AuthState
    ├── profile/         # User profile, city & contact management
    ├── rides/           # Ride creation, search, filtering & details
    ├── requests/        # Ride requests, atomic seat booking & approvals
    ├── agreement/       # Travel coordination & mutual confirmation
    └── chat/            # Realtime private in-app messaging
```

---

## 4. Zero-Cost Infrastructure Allocation

| Service | Tier | Usage in Bahar Chale | Quota Limits |
| :--- | :--- | :--- | :--- |
| **Supabase Database** | Free Tier | Postgres, Auth, RPC, Realtime | 500 MB DB, 50k MAU, 2M Realtime msgs |
| **Cloudflare Pages** | Free Tier | Web hosting & global CDN | Unlimited requests, 500 builds/month |
| **Google Maps** | Free URL Schemes | Open coordinates / addresses in Google Maps app / web | ₹0 / Unlimited |
| **GitHub** | Free Tier | Git repository, version control & actions | 2,000 CI minutes/month |
