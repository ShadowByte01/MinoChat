import 'package:flutter/material.dart';

/// Mino Chat — Lavender Mint palette.
///
/// Soft, calm, modern. Designed to feel friendly (cute) without being childish.
/// Works in both light and dark. All accent colors are tunable in settings.

class MinoColors {
  MinoColors._();

  // ---- Light ----
  static const Color background = Color(0xFFFAF9F6); // cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F2EE);
  static const Color primary = Color(0xFF7C5CFC);   // lavender
  static const Color primaryContainer = Color(0xFFE8DEFB);
  static const Color secondary = Color(0xFF34D399);  // mint
  static const Color secondaryContainer = Color(0xFFD1FADF);
  static const Color accent = Color(0xFFF87171);     // coral
  static const Color onBackground = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8B8B9A);
  static const Color outline = Color(0xFFE5E2DA);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Bubble colors
  static const Color bubbleOut = Color(0xFFE8DEFB);  // me
  static const Color bubbleIn  = Color(0xFFF3F2EE);  // them

  // ---- Dark ----
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1A1925);
  static const Color surfaceVariantDark = Color(0xFF252434);
  static const Color primaryDark = Color(0xFFA78BFA);
  static const Color primaryContainerDark = Color(0xFF3A2E63);
  static const Color secondaryDark = Color(0xFF6EE7B7);
  static const Color secondaryContainerDark = Color(0xFF1B3A2E);
  static const Color accentDark = Color(0xFFFCA5A5);
  static const Color onBackgroundDark = Color(0xFFF5F4F7);
  static const Color onSurfaceDark = Color(0xFFF5F4F7);
  static const Color mutedDark = Color(0xFF8B8B9A);
  static const Color outlineDark = Color(0xFF2E2D3E);
  static const Color bubbleOutDark = Color(0xFF3A2E63);
  static const Color bubbleInDark = Color(0xFF252434);
}

class MinoGradients {
  MinoGradients._();

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF34D399)],
  );

  static const LinearGradient liveBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF87171), Color(0xFFF59E0B)],
  );

  static const LinearGradient storyRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF34D399), Color(0xFFF87171)],
  );

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF9F6), Color(0xFFE8DEFB)],
  );
}

class MinoShadows {
  MinoShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.06),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> bubble = [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.04),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.05),
      offset: const Offset(0, 6),
      blurRadius: 18,
    ),
  ];
}

class MinoRadius {
  MinoRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
