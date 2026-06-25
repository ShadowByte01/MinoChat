# Mino Chat — Roadmap

This is a living document. Items move from **Planned** → **In Progress** → **Shipped**. Priorities are driven by community feedback — open an issue to vote.

## 🎯 Vision

Make Mino Chat the most immersive, privacy-respecting, **and** offline-capable chat app for small communities (100–500 people). Online or completely offline, Mino should "just work."

## ✅ Shipped (v0.1)

- [x] Google Sign-In only (no OTP, no phone, no email/password)
- [x] 1:1 + group chats (up to 500 members)
- [x] Text messages with replies, forwards, edits, deletes
- [x] Reactions (emoji picker)
- [x] Read receipts + typing indicators + presence
- [x] Voice notes (press-and-hold, lock mode, waveform)
- [x] File sharing — all formats, up to 2 GB
- [x] Image / video previews
- [x] Pin / mute / archive chats
- [x] Stories (image / video / text, 24h expiry)
- [x] Channels (broadcast)
- [x] Live audio rooms (Clubhouse-style, up to 500 viewers)
- [x] Live video broadcast + screen share (WebRTC signaling on Render)
- [x] 1:1 calls (audio + video)
- [x] Offline BLE mesh chat + file transfer
- [x] Foreground services for voice / live / mesh
- [x] Lavender Mint theme + dark mode
- [x] Adaptive splash + launcher icon (Android 12+)
- [x] i18n: English, Hindi, Spanish, Arabic (RTL)
- [x] Supabase schema + RLS + RPC + triggers
- [x] Edge functions: FCM token, push fan-out, live room cleanup
- [x] CI/CD via GitHub Actions
- [x] Open-source on GitHub (MIT)

## 🚧 In Progress (v0.2)

- [ ] End-to-end encrypted "secret chats" (Signal protocol via `pinenacl`)
- [ ] Disappearing messages (1h / 24h / 7d / 30d)
- [ ] Multi-device sync (currently single-device)
- [ ] In-app sticker pack maker
- [ ] Message search (full-text via Postgres `tsvector`)
- [ ] Encrypted chat backup to Supabase Storage
- [ ] Animated stickers (.tgs / Lottie)
- [ ] Custom themes (user-pickable palettes)
- [ ] Wallpaper picker per-chat
- [ ] App lock (biometric)

## 🗺️ Planned (v0.3+)

### Platforms
- [ ] iOS support (currently Android-only)
- [ ] Flutter Web (PWA)
- [ ] macOS desktop
- [ ] Windows desktop
- [ ] Linux desktop

### Live
- [ ] LiveKit integration for full SFU (replaces our signaling-only Render server)
- [ ] Multi-host live (up to 4 co-hosts on video)
- [ ] Live recording + replay
- [ ] Live donations / gifts
- [ ] Live closed captions (auto)
- [ ] Live polls + Q&A

### Chat
- [ ] Threads / replies view (Slack-style)
- [ ] Message scheduling
- [ ] Voice-to-text transcription
- [ ] AI summary of unread messages
- [ ] Polls (multi-choice, anonymous, time-bound)
- [ ] Quiz mode
- [ ] Shared calendar in groups
- [ ] Group video player (watch parties)
- [ ] Group music player (listen-along)

### Mesh
- [ ] Wi-Fi Direct mesh routing (multi-hop)
- [ ] Encrypted mesh (per-session key exchange)
- [ ] Mesh message store-and-forward (sneakernet)
- [ ] QR-code local contact exchange (no internet)
- [ ] Local-first sync between paired devices

### Privacy & Security
- [ ] Per-chat self-destruct
- [ ] Screenshot detection (Android 14+)
- [ ] Anti-screenshot blur on app background
- [ ] Spam reporting + auto-mod
- [ ] 2FA via Google re-auth
- [ ] Encrypted group invites (scannable QR)

### Polish
- [ ] Custom notification sounds per chat
- [ ] Custom chat bubbles (themeable)
- [ ] Animated stickers + GIF maker
- [ ] On-device AI sticker generator (Diffusion)
- [ ] Push notification channels per chat type
- [ ] Smart replies (on-device, offline)
- [ ] Message effects (confetti, hearts, etc.)

## 💡 Dreams (long-term)

- Federated protocol (Mino ↔ Mino servers)
- Bridge to Matrix / XMPP / ActivityPub
- Self-hostable backend (single Render + Supabase stack)
- Wear OS companion app
- Android Auto / Automotive integration for voice replies
- Accessibility: full screen reader + switch control support

## 🗓️ Release Cadence

- **Patch (0.1.x)** — bug fixes, every 1–2 weeks
- **Minor (0.x.0)** — new features, every 4–6 weeks
- **Major (1.0+)** — breaking changes, rare and well-communicated

## 🗳️ How to Influence

1. **Vote** — react with 👍 on existing issues
2. **Propose** — open a new issue with the **Feature request** template
3. **Build** — claim an issue, open a PR (see CONTRIBUTING.md)
4. **Sponsor** — financial support lets us buy LiveKit credits, Render nodes, etc.

---

Made with 💜 by **Lost Weeds (Abhinit)** · **X Hub**
