# Bahar Chale — Deployment & Mobile APK Guide

## 1. Prerequisites
- Flutter SDK 3.50+ / Dart 3.14+
- Supabase project credentials in `.env`
- Android Studio / Android SDK (for building APK)
- Cloudflare Pages account (for Flutter Web hosting)

## 2. Environment Configuration
Create `.env` based on `.env.example`:
```bash
SUPABASE_URL=https://iswbhvtosueavuzavtbr.supabase.co
SUPABASE_ANON_KEY=<your_anon_key>
SUPABASE_PUBLISHABLE_KEY=<your_publishable_key>
GOOGLE_WEB_CLIENT_ID=<optional_web_client_id_from_google_cloud>
```

## 3. Google Sign-In Configuration (Supabase & Mobile)

### A. Google Cloud Console:
1. Navigate to **Google Cloud Console** > **APIs & Services** > **Credentials**.
2. Create **OAuth 2.0 Client ID** of type **Web Application**:
   - **Authorized JavaScript origins**:
     - `https://iswbhvtosueavuzavtbr.supabase.co`
     - `http://localhost:8085`
   - **Authorized redirect URIs**:
     - `https://iswbhvtosueavuzavtbr.supabase.co/auth/v1/callback`
3. Save the generated **Client ID** and **Client Secret**.

### B. Supabase Dashboard:
1. Open your Supabase project: `https://supabase.com/dashboard/project/iswbhvtosueavuzavtbr`
2. Go to **Authentication** > **Providers** > **Google**.
3. Toggle **Enable Google provider**.
4. Paste the **Client ID** and **Client Secret**.
5. In **Authentication** > **URL Configuration** > **Redirect URLs**, add:
   - `io.supabase.baharchale://login-callback`
   - `baharchale://login-callback`
   - `http://localhost:8085`
6. Click **Save**.

### C. Android Deep Linking Support:
The Android manifest is pre-configured with intent filters for:
- Scheme: `io.supabase.baharchale` with Host `login-callback`
- Scheme: `baharchale` with Host `login-callback`
- Internet & network state permissions.

---

## 4. Android APK Build & Testing

### 1. Build Command:
```bash
flutter build apk --release
```

### 2. Output APK Path:
```bash
build/app/outputs/flutter-apk/app-release.apk
```
*(The release APK is signed with debug keys so it installs immediately on any Android device without keystore setup).*

### 3. Installing on Android Device:
- **Via USB / ADB:**
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-release.apk
  ```
- **Via Direct Transfer:**
  Copy `app-release.apk` to Google Drive, Telegram, or WhatsApp and open on your mobile phone to install.

---

## 5. Web Deployment (Cloudflare Pages)
1. Build Flutter Web:
   ```bash
   flutter build web --release
   ```
2. Deploy `build/web` to Cloudflare Pages:
   ```bash
   npx wrangler pages deploy build/web --project-name=bahar-chale
   ```
3. Cloudflare Pages automatically handles `_redirects` (`/* /index.html 200`).

---

## 6. Supabase Free Plan Operational Guidance
- Free plan projects pause after 7 days of inactivity. Ensure periodic activity or keepalive calls during the pilot.
- Backups: Export database schema and table dumps periodically via `supabase db dump`.
