# Bahar Chale — Deployment Guide

## 1. Prerequisites
- Flutter SDK 3.50+ / Dart 3.14+
- Supabase project credentials in `.env`
- Android Studio / Android SDK (for Android APK build)
- Cloudflare Pages account (for Flutter Web hosting)

## 2. Environment Configuration
Create `.env` based on `.env.example`:
```bash
SUPABASE_URL=https://iswbhvtosueavuzavtbr.supabase.co
SUPABASE_ANON_KEY=<your_anon_key>
SUPABASE_PUBLISHABLE_KEY=<your_publishable_key>
```

## 3. Web Deployment (Cloudflare Pages)
1. Build Flutter Web:
   ```bash
   flutter build web --release
   ```
2. Deploy `build/web` to Cloudflare Pages:
   ```bash
   npx wrangler pages deploy build/web --project-name=bahar-chale
   ```
3. Configure SPA redirect: Cloudflare Pages automatically handles `_redirects` (`/* /index.html 200`).

## 4. Android Build
1. Build release APK:
   ```bash
   flutter build apk --release
   ```
2. Output path: `build/app/outputs/flutter-apk/app-release.apk`
3. Distribute APK to 10 pilot users.

## 5. Supabase Free Plan Operational Guidance
- Free plan projects pause after 7 days of inactivity. Ensure periodic activity or keepalive calls during the pilot.
- Backups: Export database schema and table dumps periodically via `supabase db dump`.
