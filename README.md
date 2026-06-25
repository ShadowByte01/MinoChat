<div align="center">

# Mino Chat

**Chat without limits.** Online + offline mesh, live audio/video, voice notes, file sharing — all in one immersive, minimal & cute app.

![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)
![Kotlin](https://img.shields.io/badge/Kotlin-1.9-7F52FF?logo=kotlin)
![Supabase](https://img.shields.io/badge/Supabase-Postgres%20+%20Realtime-3ECF8E?logo=supabase)
![Render](https://img.shields.io/badge/Render-WebRTC%20Signaling-46E3B7?logo=render)
![License](https://img.shields.io/badge/License-MIT-blue)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)

</div>

---

> **Mino Chat** is an open-source, immersive chat app inspired by WhatsApp, Telegram, and Line.
> Built with Flutter + Kotlin + Supabase + Render. Made with love by **Lost Weeds (Abhinit)**, owned by **X Hub**.

## ✨ Features

### Core
- **Google Sign-In only** — no OTP, no email/password, no phone. One tap and you're in.
- **1:1 + group chats** — up to 500 members per group
- **Rich messages** — text, replies, forwards, edits, deletes, reactions, polls, contacts, locations
- **Voice notes** — press-and-hold to record, waveform preview, lock mode, up to 10 min
- **File sharing** — all formats, up to 2 GB per file, progress + previews (image / video / pdf / archive / doc / audio)
- **Stories** — image / video / text stories with 24h expiry, color picker, reactions
- **Channels** — broadcast channels for one-to-many publishing
- **Calls** — 1:1 and group audio/video calls (WebRTC)
- **Live rooms** — audio rooms (Clubhouse-style), video broadcasts, screen share — up to 500 viewers

### Offline Mesh (Bluetooth + Wi-Fi Direct)
- **BLE chat** — discover + chat with nearby Mino users without internet
- **BLE file transfer** — send files peer-to-peer over Bluetooth
- **Wi-Fi Direct** — faster file transfer for larger files via `nearby_connections`
- **Foreground service** — keeps mesh alive in background (Android)

### Polish
- **Lavender Mint theme** — soft, calm, modern, cute
- **Dark mode** — automatic + manual toggle
- **Adaptive splash + icons** — Android 12+ SplashScreen API
- **Read receipts, typing indicators, presence**
- **Pin / mute / archive chats**
- **Encrypted local storage** (Hive + secure storage)
- **i18n** — English, Hindi, Spanish, Arabic (RTL-ready)
- **Offline-first** — messages queued and synced when back online

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                        Flutter App                        │
│  Riverpod · GoRouter · Hive · Freezed · Material 3        │
└───────┬───────────────────────────────┬───────────────────┘
        │                               │
        ▼                               ▼
┌──────────────────┐         ┌──────────────────────┐
│   Supabase       │         │   Render             │
│  ──────────────  │         │  ──────────────────  │
│  • Auth (Google) │         │  • WebRTC signaling  │
│  • Postgres +    │         │  • SFU-ready (swap   │
│    Realtime      │         │    for LiveKit)      │
│  • Storage       │         │  • WebSocket /ws     │
│  • Edge Functions│         │                      │
└──────────────────┘         └──────────────────────┘
        │
        ▼
┌──────────────────┐
│  Android Native  │
│  ──────────────  │
│  • BLE GATT      │
│  • Foreground    │
│    services      │
│  • Google Auth   │
└──────────────────┘
```

**Why this split?**
- **Supabase** owns auth, persistent data, realtime pub/sub, and file storage — managed, scalable, free tier covers the entire small-group use case.
- **Render** runs only the WebRTC signaling server (and optionally an SFU). It's cheap to host and easy to scale horizontally.
- **Android native (Kotlin)** handles BLE mesh + foreground services — things Flutter plugins alone can't keep alive reliably.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.22+
- Dart 3.4+
- Android SDK 34 (minSdk 24)
- A Supabase project
- A Google Cloud OAuth client (Android + Web)
- (Optional) A Render account

### 1. Clone
```bash
git clone https://github.com/xhub/mino_chat.git
cd mino_chat
flutter pub get
```

### 2. Configure environment
```bash
cp .env.example .env
# Fill in your Supabase URL + anon key + Google OAuth client IDs
```

Or pass via `--dart-define`:
```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=...
```

### 3. Apply Supabase schema
```bash
# Install supabase CLI: https://supabase.com/docs/guides/cli
supabase db push
```
Or paste `supabase/migrations/0001_initial.sql` into the Supabase SQL editor.

### 4. Set up Google Sign-In
1. **Google Cloud Console** → APIs & Services → Credentials → Create OAuth client ID
   - **Application type:** Android
   - **Package name:** `com.xhub.minochat`
   - **SHA-1:** `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
2. **Supabase dashboard** → Authentication → Providers → Google → enable, paste the Web client ID + secret
3. Add the Web client ID to `.env` as `GOOGLE_WEB_CLIENT_ID`

### 5. (Optional) Deploy Render signaling server
```bash
cd render_server
# Connect your GitHub repo on Render dashboard, it'll auto-detect render.yaml
# Or use the Render CLI:
render deploy
```

### 6. Run
```bash
flutter run
```

### 7. Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 Project Structure

```
mino_chat/
├── android/                    # Kotlin native (BLE, foreground services, MainActivity)
│   └── app/src/main/
│       ├── kotlin/com/xhub/minochat/
│       │   ├── MainActivity.kt
│       │   ├── ble/MinoBleBridge.kt       # BLE GATT server + client
│       │   ├── service/MinoMeshService.kt # Foreground mesh keep-alive
│       │   └── voice/MinoVoiceService.kt  # Foreground voice/live
│       └── res/                            # Icons, splash, themes, manifest
├── lib/                        # Flutter / Dart
│   ├── core/                   # Constants, theme, router, utils, errors
│   ├── data/                   # Models, Supabase repository, storage
│   ├── features/
│   │   ├── auth/               # Google Sign-In only (no OTP)
│   │   ├── chat/               # 1:1 + group + message bubbles + list
│   │   ├── voice/              # Voice recorder bar + waveform
│   │   ├── files/              # File picker + attachment helpers
│   │   ├── live/               # Audio rooms + video broadcast
│   │   ├── bluetooth/          # BLE mesh screens + controller
│   │   ├── stories/            # Story viewer + camera
│   │   ├── channels/           # Broadcast channels
│   │   ├── calls/              # 1:1 + group calls
│   │   ├── profile/            # User profile
│   │   └── settings/           # Settings + privacy + themes
│   ├── widgets/                # Shared widgets
│   └── main.dart
├── assets/
│   ├── images/logo.png         # Mino Chat logo (1254×1254)
│   ├── fonts/                  # Plus Jakarta Sans (optional)
│   └── sounds/
├── l10n/                       # ARB files (en, hi, es, ar)
├── supabase/
│   ├── migrations/             # SQL schema + RLS + RPC + triggers
│   └── functions/              # Edge functions (fcm-token, push-fanout, live-schedule)
├── render_server/              # Node.js WebRTC signaling + Dockerfile
├── .github/
│   ├── workflows/              # CI/CD
│   └── ISSUE_TEMPLATE/
├── pubspec.yaml
├── analysis_options.yaml
├── render.yaml
└── README.md
```

## 🔐 Security & Privacy

- **Google Sign-In only** — no passwords to leak
- **Row-Level Security** on every Supabase table — users can only read/write what they're a member of
- **Encrypted local storage** via `flutter_secure_storage` + Hive
- **No phone number** required at any point
- **Read receipts and last-seen** are toggleable in Settings
- **E2E encryption for secret chats** is on the roadmap (see [ROADMAP.md](ROADMAP.md))

## 🌱 Roadmap

See [ROADMAP.md](ROADMAP.md) for the full plan. Highlights:
- [ ] End-to-end encrypted "secret chats" (Signal protocol)
- [ ] Disappearing messages
- [ ] Multi-device sync
- [ ] iOS support (currently Android-only)
- [ ] Desktop (macOS / Windows / Linux)
- [ ] Custom stickers + GIF maker
- [ ] LiveKit integration for full SFU
- [ ] Web app (Flutter Web)

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and our [Code of Conduct](CODE_OF_CONDUCT.md) before opening a PR.

Quick start:
1. Fork → branch `feat/your-feature`
2. `flutter analyze` must pass
3. `flutter test` must pass
4. Open a PR using the template

## 📜 License

MIT — see [LICENSE](LICENSE).

## 💜 Credits

- **Made by:** [Lost Weeds (Abhinit)](https://github.com/lostweeds) — `lostweeds`
- **Owned by:** **X Hub**
- **Inspired by:** WhatsApp, Telegram, Line, Signal
- **Built with:** Flutter, Kotlin, Supabase, Render, WebRTC, Flutter Blue Plus, LiveKit Client, and many amazing open-source packages

<div align="center">

**Mino Chat** · Made with 💜 by Lost Weeds · © X Hub

</div>
