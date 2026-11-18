# Bahar Chale (बाहर चलें)

> **सफर साथ में, आसान हर राह।**  
> Lightweight community ride-sharing & collective journey coordination platform for Android and Web.

[![Production CI/CD Pipeline](https://github.com/shubha95m/bahar-chale/actions/workflows/deploy.yml/badge.svg)](https://github.com/shubha95m/bahar-chale/actions/workflows/deploy.yml)
[![Live Web Application](https://img.shields.io/badge/Web%20App-GitHub%20Pages-2ea44f?logo=github)](https://shubha95m.github.io/bahar-chale/)
[![Download APK](https://img.shields.io/badge/Download-Android%20APK-0F766E?logo=android)](https://iswbhvtosueavuzavtbr.supabase.co/storage/v1/object/public/releases/bahar-chale.apk)

---

## 🚀 Live Deployments & Downloads

- **🌐 Hosted Web Application (PWA):**  
  👉 **[https://shubha95m.github.io/bahar-chale/](https://shubha95m.github.io/bahar-chale/)**
- **📱 Android Release APK (Direct Cloud Download):**  
  👉 **[bahar-chale.apk](https://iswbhvtosueavuzavtbr.supabase.co/storage/v1/object/public/releases/bahar-chale.apk)** *(~21.8 MB, ARM64 optimized)*
- **📦 GitHub Releases:**  
  👉 **[github.com/shubha95m/bahar-chale/releases](https://github.com/shubha95m/bahar-chale/releases)**
- **💻 Local Web Server:**  
  👉 **[http://localhost:8085](http://localhost:8085)**

---

## Highlights

- **Lightweight & Clean:** No commercial cab commissions, no payment gateways, no meters, no bloated analytics dashboards.
- **₹0/Month Infrastructure:** Built entirely using free-tier services (Supabase Free, GitHub Pages Free, Google Maps deep link intents).
- **Hindi-First Interface:** Intuitive, friendly UI designed for quick readability and high touch targets on mobile devices.
- **Offline-Ready:** Dual-layer architecture with Supabase Cloud Postgres as source of truth and local SQLite cache with an idempotent sync outbox.
- **Privacy & Security First:** 100% RLS enforcement, atomic seat allocation, and mutual agreement confirmation before travel.

---

## Tech Stack

- **Frontend:** Flutter 3.50+ / Dart 3.14+ (Material 3)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Routing:** GoRouter (`go_router`) with reactive auth stream listenables
- **Backend / Database:** Supabase PostgreSQL (`ap-south-1` Mumbai)
- **Realtime:** Supabase Realtime WebSocket engine
- **Local Cache:** SQLite (`sqflite` / `sqflite_common_ffi`)
- **Maps:** Native Google Maps URL intents (Zero API cost)
- **Auth:** Google Sign-In with PKCE flow & 1-click Demo bypass accounts

---

## Live End-to-End Testing Guide

### 1. Open the Hosted Web App
Open **[https://shubha95m.github.io/bahar-chale/](https://shubha95m.github.io/bahar-chale/)** in your browser.

### 2. Sign In
- **Demo Mode:** Click **"⚡ डेमो मोड: चालक (Driver) के रूप में प्रवेश"** or **"👥 डेमो मोड: यात्री (Rider) के रूप में प्रवेश"** for instant 1-click login.
- **Google Sign-In:** Click **"Google से साइन इन करें"** to authenticate with your Google account.

### 3. Coordinate a Ride
1. **Driver:** Tap **"सवारी ऑफर करें"** → Post a ride (e.g. Pune → Mumbai, 3 seats, ₹250).
2. **Rider:** In a private window, tap **"सवारी खोजें"** → Search Pune → Mumbai → Send request for 1 seat.
3. **Driver:** View Home dashboard alert banner → Tap **"स्वीकार करें"** (atomic seat allocation).
4. **Mutual Agreement:** Both parties open **"सहमति देखें"** → Tap **"सहमति की पुष्टि करें"** → Status turns to **पुष्ट (Confirmed)**.
5. **Real-time Chat:** Tap **"संदेश भेजें"** to exchange real-time coordinates and pickup details.

---

## Local Development

```bash
# Clone
git clone https://github.com/shubha95m/bahar-chale.git
cd bahar-chale

# Install
flutter pub get

# Run on Web
flutter run -d chrome

# Run on Android
flutter run -d android
```
