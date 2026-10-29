import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Material 3 themes built from the design tokens.
abstract final class AppTheme {
  /// Light theme.
  static ThemeData get light =>
      _build(Brightness.light, const AppPalette.light());

  /// Dark theme.
  static ThemeData get dark => _build(Brightness.dark, const AppPalette.dark());

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: brightness,
        ).copyWith(
          primary: p.accent,
          onPrimary: brightness == Brightness.light
              ? AppColors.surface
              : AppColors.darkGround,
          primaryContainer: p.accentWash,
          onPrimaryContainer: p.accent,
          secondary: p.navy,
          onSecondary: p.onNavy,
          surface: p.surface,
          onSurface: p.ink,
          onSurfaceVariant: p.inkSecondary,
          outline: p.hairline,
          outlineVariant: p.hairline,
          error: p.negative,
          surfaceContainerHighest: p.cardGround,
        );
    final textTheme = _textTheme(p);
    const inputBorder = OutlineInputBorder(
      borderRadius: AppRadii.pillBorder,
      borderSide: BorderSide.none,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.ground,
      canvasColor: p.ground,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      dividerColor: p.hairline,
      extensions: [p],
      splashFactory: NoSplash.splashFactory,
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.fill,
        hintStyle: AppTypography.body.copyWith(color: p.inkTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4l - AppSpacing.xs / 2,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.ink, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: p.navy),
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, AppSizes.control),
          shape: const StadiumBorder(),
          textStyle: AppTypography.button,
        ),
      ),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    TextStyle s(TextStyle base, Color c) => base.copyWith(color: c);
    return TextTheme(
      displayLarge: s(AppTypography.display, p.ink),
      displayMedium: s(AppTypography.headline, p.ink),
      displaySmall: s(AppTypography.big, p.ink),
      headlineLarge: s(AppTypography.headline, p.heading),
      headlineMedium: s(AppTypography.brand, p.ink),
      headlineSmall: s(AppTypography.title, p.ink),
      titleLarge: s(AppTypography.title, p.ink),
      titleMedium: s(AppTypography.subtitle, p.ink),
      titleSmall: s(AppTypography.bodyMedium, p.ink),
      bodyLarge: s(AppTypography.bodyLarge, p.inkSecondary),
      bodyMedium: s(AppTypography.body, p.ink),
      bodySmall: s(AppTypography.small, p.inkTertiary),
      labelLarge: s(AppTypography.button, p.ink),
      labelMedium: s(AppTypography.smallMedium, p.ink),
      labelSmall: s(AppTypography.chip, p.ink),
    );
  }
}
