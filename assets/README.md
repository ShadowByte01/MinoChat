# Mino Chat — Local Assets

This folder holds optional local assets.

## Fonts
The app uses Google Fonts (`Plus Jakarta Sans`) loaded at runtime — no local font files required.
If you want to bundle fonts for offline use, drop `.ttf` files here and update `pubspec.yaml`'s `fonts:` section with the matching paths.

## Sounds
Drop short notification / message-sent sounds here (`.mp3` or `.wav`).
Wire them up via `audioplayers` in `lib/features/...`.

## Lottie
Drop `.json` Lottie animations here for things like message-sent confirmation, story-loader, etc.

## Icons
SVG icons live here. Already used in pubspec: `flutter_svg`.

_Made by Lost Weeds (Abhinit) · X Hub · MIT License_
