import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Mino Chat — typography & full Material 3 theme.
/// Built around Plus Jakarta Sans (cute + readable + supports Latin Extended).

class MinoTypography {
  MinoTypography._();

  static TextTheme get base {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12, height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2),
    );
  }
}

class MinoTheme {
  MinoTheme._();

  static ThemeData light() {
    final scheme = const ColorScheme.light(
      primary: MinoColors.primary,
      onPrimary: MinoColors.onPrimary,
      secondary: MinoColors.secondary,
      onSecondary: MinoColors.onPrimary,
      error: MinoColors.error,
      surface: MinoColors.surface,
      onSurface: MinoColors.onSurface,
      background: MinoColors.background,
      onBackground: MinoColors.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: MinoColors.background,
      canvasColor: MinoColors.background,
      textTheme: MinoTypography.base,
      appBarTheme: AppBarTheme(
        backgroundColor: MinoColors.background,
        foregroundColor: MinoColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MinoColors.onBackground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MinoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinoRadius.lg),
          side: const BorderSide(color: MinoColors.outline, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MinoColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: const BorderSide(color: MinoColors.outline, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: const BorderSide(color: MinoColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: const BorderSide(color: MinoColors.error, width: 1),
        ),
        labelStyle: const TextStyle(color: MinoColors.muted),
        hintStyle: const TextStyle(color: MinoColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MinoColors.primary,
          foregroundColor: MinoColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinoRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MinoColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MinoColors.primary,
          side: const BorderSide(color: MinoColors.primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinoRadius.md),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: MinoColors.onBackground, size: 22),
      dividerTheme: const DividerThemeData(
        color: MinoColors.outline,
        thickness: 0.5,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MinoColors.surfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, color: MinoColors.onBackground),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinoRadius.pill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MinoColors.onBackground,
        contentTextStyle: const TextStyle(color: MinoColors.background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MinoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(MinoRadius.xl)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MinoColors.surface,
        elevation: 0,
        height: 64,
        indicatorColor: MinoColors.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = const ColorScheme.dark(
      primary: MinoColors.primaryDark,
      onPrimary: MinoColors.onPrimary,
      secondary: MinoColors.secondaryDark,
      onSecondary: Color(0xFF0F0E17),
      error: MinoColors.error,
      surface: MinoColors.surfaceDark,
      onSurface: MinoColors.onSurfaceDark,
      background: MinoColors.backgroundDark,
      onBackground: MinoColors.onBackgroundDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: MinoColors.backgroundDark,
      canvasColor: MinoColors.backgroundDark,
      textTheme: MinoTypography.base,
      appBarTheme: AppBarTheme(
        backgroundColor: MinoColors.backgroundDark,
        foregroundColor: MinoColors.onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MinoColors.onSurfaceDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MinoColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinoRadius.lg),
          side: const BorderSide(color: MinoColors.outlineDark, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MinoColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: const BorderSide(color: MinoColors.outlineDark, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinoRadius.md),
          borderSide: const BorderSide(color: MinoColors.primaryDark, width: 1.5),
        ),
        labelStyle: const TextStyle(color: MinoColors.mutedDark),
        hintStyle: const TextStyle(color: MinoColors.mutedDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MinoColors.primaryDark,
          foregroundColor: const Color(0xFF0F0E17),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinoRadius.md),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: MinoColors.onSurfaceDark, size: 22),
      dividerTheme: const DividerThemeData(
        color: MinoColors.outlineDark,
        thickness: 0.5,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MinoColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(MinoRadius.xl)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MinoColors.surfaceDark,
        elevation: 0,
        height: 64,
        indicatorColor: MinoColors.primaryContainerDark,
      ),
    );
  }
}
