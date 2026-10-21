import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Semantic color roles that adapt to light and dark mode.
///
/// Read it with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Creates a palette.
  const AppPalette({
    required this.ground,
    required this.cardGround,
    required this.surface,
    required this.navy,
    required this.navyAlt,
    required this.onNavy,
    required this.onNavyMuted,
    required this.onNavyFill,
    required this.sky,
    required this.ink,
    required this.heading,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.fill,
    required this.hairline,
    required this.accent,
    required this.accentWash,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.incident,
    required this.warningWash,
    required this.negativeWash,
    required this.positiveWash,
    required this.slowWash,
    required this.scrim,
  });

  /// Light palette taken from the React demo.
  const AppPalette.light()
    : this(
        ground: AppColors.ground,
        cardGround: AppColors.cardGround,
        surface: AppColors.surface,
        navy: AppColors.navy,
        navyAlt: AppColors.navy2,
        onNavy: const Color(0xFFFFFFFF),
        onNavyMuted: const Color(0x8FFFFFFF),
        onNavyFill: const Color(0x24FFFFFF),
        sky: AppColors.sky,
        ink: AppColors.ink,
        heading: AppColors.navy,
        inkSecondary: const Color(0xC7191817),
        inkTertiary: const Color(0x8F191817),
        fill: const Color(0x0F191817),
        hairline: const Color(0x1A191817),
        accent: AppColors.accent,
        accentWash: const Color(0x1F2A48DE),
        positive: AppColors.positive,
        negative: AppColors.negative,
        warning: AppColors.warning,
        incident: AppColors.incident,
        warningWash: AppColors.warningWash,
        negativeWash: AppColors.negativeWash,
        positiveWash: AppColors.positiveWash,
        slowWash: AppColors.slowWash,
        scrim: AppElevation.scrim,
      );

  /// Dark palette derived from the brand navy.
  const AppPalette.dark()
    : this(
        ground: AppColors.darkGround,
        cardGround: AppColors.darkCardGround,
        surface: AppColors.darkSurface,
        navy: const Color(0xFF050B22),
        navyAlt: AppColors.navy2,
        onNavy: const Color(0xFFFFFFFF),
        onNavyMuted: const Color(0x8FFFFFFF),
        onNavyFill: const Color(0x24FFFFFF),
        sky: AppColors.sky,
        ink: AppColors.darkInk,
        heading: AppColors.darkInk,
        inkSecondary: const Color(0xC7F3F4F8),
        inkTertiary: const Color(0x8FF3F4F8),
        fill: const Color(0x14FFFFFF),
        hairline: const Color(0x24FFFFFF),
        accent: AppColors.darkAccent,
        accentWash: const Color(0x2E7C93FF),
        positive: AppColors.positiveOnNavy,
        negative: AppColors.negativeOnNavy,
        warning: AppColors.warning,
        incident: const Color(0xFFFF9A5C),
        warningWash: const Color(0x33F5A524),
        negativeWash: const Color(0x33E0353B),
        positiveWash: const Color(0x331FA567),
        slowWash: const Color(0x29E0353B),
        scrim: const Color(0x99000000),
      );

  /// Page background.
  final Color ground;

  /// Inset background for rows inside cards.
  final Color cardGround;

  /// Card surface.
  final Color surface;

  /// Navy panel background.
  final Color navy;

  /// Secondary navy.
  final Color navyAlt;

  /// Primary content on navy.
  final Color onNavy;

  /// Muted content on navy.
  final Color onNavyMuted;

  /// Translucent fill on navy.
  final Color onNavyFill;

  /// Periwinkle highlight on navy.
  final Color sky;

  /// Primary text.
  final Color ink;

  /// Heading color (navy in light mode).
  final Color heading;

  /// Secondary text.
  final Color inkSecondary;

  /// Tertiary text.
  final Color inkTertiary;

  /// Subtle fill (ghost buttons, skeletons, tracks).
  final Color fill;

  /// Hairline borders.
  final Color hairline;

  /// Brand accent.
  final Color accent;

  /// Translucent accent background.
  final Color accentWash;

  /// Positive state.
  final Color positive;

  /// Negative state.
  final Color negative;

  /// Warning state.
  final Color warning;

  /// Incident tag color.
  final Color incident;

  /// Warning background.
  final Color warningWash;

  /// Negative background.
  final Color negativeWash;

  /// Positive background.
  final Color positiveWash;

  /// Slow courier background.
  final Color slowWash;

  /// Plain dialog scrim.
  final Color scrim;

  @override
  AppPalette copyWith({
    Color? ground,
    Color? cardGround,
    Color? surface,
    Color? navy,
    Color? accent,
    Color? ink,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      cardGround: cardGround ?? this.cardGround,
      surface: surface ?? this.surface,
      navy: navy ?? this.navy,
      navyAlt: navyAlt,
      onNavy: onNavy,
      onNavyMuted: onNavyMuted,
      onNavyFill: onNavyFill,
      sky: sky,
      ink: ink ?? this.ink,
      heading: heading,
      inkSecondary: inkSecondary,
      inkTertiary: inkTertiary,
      fill: fill,
      hairline: hairline,
      accent: accent ?? this.accent,
      accentWash: accentWash,
      positive: positive,
      negative: negative,
      warning: warning,
      incident: incident,
      warningWash: warningWash,
      negativeWash: negativeWash,
      positiveWash: positiveWash,
      slowWash: slowWash,
      scrim: scrim,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ground: l(ground, other.ground),
      cardGround: l(cardGround, other.cardGround),
      surface: l(surface, other.surface),
      navy: l(navy, other.navy),
      navyAlt: l(navyAlt, other.navyAlt),
      onNavy: l(onNavy, other.onNavy),
      onNavyMuted: l(onNavyMuted, other.onNavyMuted),
      onNavyFill: l(onNavyFill, other.onNavyFill),
      sky: l(sky, other.sky),
      ink: l(ink, other.ink),
      heading: l(heading, other.heading),
      inkSecondary: l(inkSecondary, other.inkSecondary),
      inkTertiary: l(inkTertiary, other.inkTertiary),
      fill: l(fill, other.fill),
      hairline: l(hairline, other.hairline),
      accent: l(accent, other.accent),
      accentWash: l(accentWash, other.accentWash),
      positive: l(positive, other.positive),
      negative: l(negative, other.negative),
      warning: l(warning, other.warning),
      incident: l(incident, other.incident),
      warningWash: l(warningWash, other.warningWash),
      negativeWash: l(negativeWash, other.negativeWash),
      positiveWash: l(positiveWash, other.positiveWash),
      slowWash: l(slowWash, other.slowWash),
      scrim: l(scrim, other.scrim),
    );
  }
}

/// Shortcut to [AppPalette] from a [BuildContext].
extension AppPaletteContext on BuildContext {
  /// The active [AppPalette].
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? const AppPalette.light();
}
