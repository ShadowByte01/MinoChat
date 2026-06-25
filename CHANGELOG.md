# Mino Chat — Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- E2E encrypted "secret chats" (Signal protocol)
- Disappearing messages
- iOS support
- LiveKit SFU integration

## [0.1.0] — 2025-06-26

### Added
- Initial public release 🎉
- **Auth:** Google Sign-In only (no OTP, no email/password, no phone)
- **Chat:** 1:1 + group (up to 500 members) with replies, forwards, edits, deletes, reactions, polls, contacts, locations
- **Voice notes:** press-and-hold to record, waveform, lock mode, up to 10 min
- **File sharing:** all formats, up to 2 GB, with previews
- **Stories:** image / video / text, 24h expiry, color picker
- **Channels:** broadcast channels for one-to-many publishing
- **Live rooms:** audio (Clubhouse-style), video broadcast, screen share — up to 500 viewers
- **Calls:** 1:1 audio + video (WebRTC)
- **Offline mesh:** BLE chat + file transfer with foreground keep-alive service
- **i18n:** English, Hindi, Spanish, Arabic (RTL-ready)
- **Theme:** Lavender Mint palette + dark mode + adaptive splash + launcher icons
- **Backend:** Supabase schema with RLS, RPC functions, triggers; Render WebRTC signaling server
- **Edge functions:** FCM token, push fan-out, live room cleanup
- **CI/CD:** GitHub Actions for analyze + test + build APK
- **Open source:** MIT license, CONTRIBUTING, COC, ROADMAP, issue/PR templates

### Credits
- Made by **Lost Weeds (Abhinit)**
- Owned by **X Hub**
- Inspired by WhatsApp, Telegram, Line, Signal
