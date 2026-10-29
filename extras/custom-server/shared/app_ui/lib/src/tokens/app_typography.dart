import 'package:flutter/painting.dart';

/// Text styles of the design system, set in Poppins.
abstract final class AppTypography {
  /// Font family, bundled with the package.
  static const String fontFamily = 'packages/app_ui/Poppins';

  /// Monospace family, bundled with the package.
  static const String monoFamily = 'packages/app_ui/JetBrainsMono';

  /// Fallbacks used by [mono].
  static const List<String> monoFallback = [
    'Menlo',
    'Roboto Mono',
    'monospace',
  ];

  static const double _tracking = -0.005;

  /// 28px / 500, for big numbers.
  static const TextStyle big = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.56,
    height: 1.15,
  );

  /// 32px / 500, for result headlines.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.64,
    height: 1.15,
  );

  /// 28px / 600, for dialog titles.
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
    height: 1.15,
  );

  /// 22px / 600, brand name.
  static const TextStyle brand = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.44,
  );

  /// 18px / 600, section titles.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.18,
  );

  /// 16px / 600, card titles.
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.16,
  );

  /// 15px / 400, long copy.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.55,
    letterSpacing: _tracking * 15,
  );

  /// 14px / 400, the default body.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    letterSpacing: _tracking * 14,
  );

  /// 14px / 500, emphasized body.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _tracking * 14,
  );

  /// 12px / 400, secondary info.
  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
  );

  /// 12px / 500, labels and counts.
  static const TextStyle smallMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// 11px / 400, micro captions.
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
  );

  /// 11px / 500, chips.
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// 10px / 600 uppercase, tiny tags such as "Recommended".
  static const TextStyle tag = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  /// Button label, 14px / 500.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Big button label, 16px / 500.
  static const TextStyle buttonBig = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Monospace with tabular figures, for money, clocks and scores.
  static const TextStyle mono = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFallback,
    fontSize: 12,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
