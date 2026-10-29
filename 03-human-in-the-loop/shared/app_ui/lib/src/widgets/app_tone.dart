import 'package:app_ui/src/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Semantic emphasis shared by chips, tiles and banners.
enum AppTone {
  /// Quiet gray.
  neutral,

  /// Brand blue.
  accent,

  /// Success green.
  positive,

  /// Warning amber.
  warning,

  /// Error red.
  negative,
}

/// Resolves [AppTone] into concrete colors.
extension AppToneColors on AppTone {
  /// Foreground (text and icon) color of the tone.
  Color foreground(AppPalette p) => switch (this) {
    AppTone.neutral => p.inkSecondary,
    AppTone.accent => p.accent,
    AppTone.positive => p.positive,
    AppTone.warning => p.incident,
    AppTone.negative => p.negative,
  };

  /// Background wash of the tone.
  Color background(AppPalette p) => switch (this) {
    AppTone.neutral => p.fill,
    AppTone.accent => p.accentWash,
    AppTone.positive => p.positive.withValues(alpha: 0.14),
    AppTone.warning => p.warningWash,
    AppTone.negative => p.negative.withValues(alpha: 0.12),
  };
}
