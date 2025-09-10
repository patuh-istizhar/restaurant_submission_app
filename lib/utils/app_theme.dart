import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightSeedColor = Color(0xFF0069C0);
  static const Color _darkSeedColor = Color(0xFF0069C0);

  static ColorScheme defaultLightScheme() {
    return ColorScheme.fromSeed(
      seedColor: _lightSeedColor,
      brightness: Brightness.light,
    );
  }

  static ColorScheme defaultDarkScheme() {
    return ColorScheme.fromSeed(
      seedColor: _darkSeedColor,
      brightness: Brightness.dark,
    );
  }

  static BoxDecoration containerDecoration(
    ColorScheme colorScheme, {
    double opacity = 0.3,
  }) {
    return BoxDecoration(
      color: colorScheme.surfaceContainer.withAlpha((opacity * 255).round()),
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(
        color: colorScheme.outline.withAlpha((0.2 * 255).round()),
      ),
    );
  }

  static ThemeData themeFromScheme(ColorScheme colorScheme) {
    final baseTheme = ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    final textTheme = baseTheme.textTheme.copyWith(
      displayLarge: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.displayLarge,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.displayMedium,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.displaySmall,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.headlineLarge,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.headlineMedium,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.headlineSmall,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(textStyle: baseTheme.textTheme.bodyLarge),
      bodyMedium: GoogleFonts.inter(textStyle: baseTheme.textTheme.bodyMedium),
      bodySmall: GoogleFonts.inter(textStyle: baseTheme.textTheme.bodySmall),
      labelLarge: GoogleFonts.inter(textStyle: baseTheme.textTheme.labelLarge),
      labelMedium: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.labelMedium,
      ),
      labelSmall: GoogleFonts.inter(textStyle: baseTheme.textTheme.labelSmall),
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: colorScheme.outline.withAlpha((0.2 * 255).round()),
          ),
        ),
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: baseTheme.navigationBarTheme.copyWith(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium!.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            );
          }
          return textTheme.labelMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      switchTheme: _switchThemeFromScheme(colorScheme),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        hintStyle: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primaryContainer,
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24.0),
      dividerColor: colorScheme.outline.withAlpha((0.2 * 255).round()),
    );
  }

  static SwitchThemeData _switchThemeFromScheme(ColorScheme cs) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return cs.primary;
        }
        return cs.surface;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return cs.primaryContainer.withAlpha((0.5 * 255).round());
        }
        return cs.onSurface.withAlpha((0.12 * 255).round());
      }),
    );
  }
}
