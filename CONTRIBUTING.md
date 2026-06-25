# Contributing to Mino Chat

First off — thank you for taking the time to contribute! 💜

This project is made by **Lost Weeds (Abhinit)** and owned by **X Hub**. We follow an open, inclusive, and beginner-friendly contribution model.

## 📋 Code of Conduct

Participation in this project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

## 🚀 Ways to Contribute

- 🐛 **Report bugs** — open an issue with the bug template
- 💡 **Suggest features** — open an issue with the feature template
- 📝 **Improve docs** — typos, clarity, translations
- 🌍 **Translate** — add or improve ARB files in `l10n/`
- 🎨 **Design** — icons, illustrations, themes
- 💻 **Code** — pick any [good-first-issue](https://github.com/xhub/mino_chat/labels/good%20first%20issue) or work on the [roadmap](ROADMAP.md)

## 🛠️ Development Setup

```bash
git clone https://github.com/xhub/mino_chat.git
cd mino_chat
flutter pub get
flutter run
```

You'll need:
- Flutter 3.22+
- Dart 3.4+
- Android SDK 34 (minSdk 24)
- A free Supabase project (see README → Quick Start)

## 🌿 Branching

- `main` — stable, always shippable
- `feat/<short-name>` — new features
- `fix/<short-name>` — bug fixes
- `docs/<short-name>` — documentation only
- `chore/<short-name>` — tooling, deps, CI

## 🧪 Before Opening a PR

1. **Format & analyze**
   ```bash
   dart format .
   flutter analyze
   ```
   Both must be clean (no warnings, no errors).

2. **Tests** (if you touched logic)
   ```bash
   flutter test
   ```
   Add tests for any new public function or controller.

3. **Commit style** — Conventional Commits
   ```
   feat(chat): add disappearing messages
   fix(ble): handle MTU negotiation race
   docs(readme): clarify Render deployment
   chore(deps): bump flutter_blue_plus to 1.32.7
   ```

4. **PR title** — same format as commit messages.

5. **PR description** — use the template (it'll auto-fill when you open the PR).

## 🧭 Code Style

- **Riverpod** for state — `Notifier` / `AsyncNotifier`, avoid `StatefulWidget` state for anything cross-screen.
- **Equatable** on every model — or migrate to Freezed once we enable codegen in CI.
- **Single quotes**, trailing commas, `final` locals where possible.
- **No `print()`** — use the `log` logger from `core/utils/logger.dart`.
- **Errors** — throw a `MinoFailure` subclass, never raw strings.
- **Files** — one class per file, named after the class.
- **Imports** — `package:` first, then `dart:`, then relative. Grouped with blank lines.

## 🌍 Translations

1. Edit the appropriate `l10n/app_<locale>.arb` file.
2. Run `flutter gen-l10n` to regenerate.
3. Test by switching device language.

If you're adding a new language:
1. Copy `l10n/app_en.arb` to `l10n/app_<locale>.arb`.
2. Translate every value.
3. Add the locale to `supportedLocales` in `lib/main.dart`.
4. Open a PR.

## 🐛 Reporting Bugs

Use the **Bug report** issue template. Include:
- Mino Chat version (`flutter pub deps | grep mino_chat` or check pubspec)
- Android version + device
- Steps to reproduce
- Expected vs actual behavior
- Logs (`adb logcat | grep Mino` or in-app logger)
- Screenshots / screen recordings if visual

## 💡 Suggesting Features

Use the **Feature request** issue template. Tell us:
- The user problem you're solving
- Your proposed solution
- Alternatives you've considered
- Whether you're willing to implement it

## 🏷️ Issue Labels

| Label | Meaning |
|-------|---------|
| `good first issue` | Beginner-friendly, well-scoped |
| `help wanted` | We'd love community help |
| `bug` | Something is broken |
| `feature` | New functionality |
| `enhancement` | Improvement to existing feature |
| `docs` | Documentation only |
| `i18n` | Translation work |
| `design` | UI/UX, themes, icons |
| `ble` | Bluetooth / offline mesh |
| `live` | Live rooms / WebRTC |
| `blocked` | Waiting on external dependency |

## 💜 Recognition

All contributors are listed in [CONTRIBUTORS.md](CONTRIBUTORS.md). Significant contributions may be credited in release notes.

Thank you for helping make Mino Chat awesome!

— Lost Weeds (Abhinit) · X Hub
