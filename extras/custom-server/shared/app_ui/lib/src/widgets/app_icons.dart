import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Visual weights available for an [AppIcon].
///
/// Phosphor Icons (`phosphor_flutter` 2.1.0) does not compile on Flutter 3.47
/// because `IconData` became a final class, so the set is backed by Material
/// icons. `fill` and `duotone` currently share the solid rounded glyph.
enum AppIconStyle {
  /// Outline.
  regular,

  /// Solid.
  fill,

  /// Same solid glyph as [fill]; kept so a duotone set can be swapped in.
  duotone,
}

/// One icon in three weights.
@immutable
class AppIconSet {
  /// Creates an icon set.
  const AppIconSet(this.regular, this.fill, this.duotone);

  /// Outline glyph.
  final IconData regular;

  /// Solid glyph.
  final IconData fill;

  /// Duotone glyph.
  final IconData duotone;

  /// Glyph for [style].
  IconData resolve(AppIconStyle style) => switch (style) {
    AppIconStyle.regular => regular,
    AppIconStyle.fill => fill,
    AppIconStyle.duotone => duotone,
  };
}

/// The icon vocabulary of the Coffee Manager.
abstract final class AppIcons {
  /// Coffee cup.
  static const coffee = AppIconSet(
    Icons.coffee_outlined,
    Icons.coffee_rounded,
    Icons.coffee_rounded,
  );

  /// Parcel.
  static const package = AppIconSet(
    Icons.inventory_2_outlined,
    Icons.inventory_2_rounded,
    Icons.inventory_2_rounded,
  );

  /// Scooter.
  static const moped = AppIconSet(
    Icons.moped_outlined,
    Icons.moped_rounded,
    Icons.moped_rounded,
  );

  /// Map pin.
  static const mapPin = AppIconSet(
    Icons.location_on_outlined,
    Icons.location_on_rounded,
    Icons.location_on_rounded,
  );

  /// Check in a circle.
  static const checkCircle = AppIconSet(
    Icons.check_circle_outline_rounded,
    Icons.check_circle_rounded,
    Icons.check_circle_rounded,
  );

  /// Cross in a circle.
  static const xCircle = AppIconSet(
    Icons.cancel_outlined,
    Icons.cancel_rounded,
    Icons.cancel_rounded,
  );

  /// Warning triangle.
  static const warning = AppIconSet(
    Icons.warning_amber_rounded,
    Icons.warning_rounded,
    Icons.warning_rounded,
  );

  /// Star.
  static const star = AppIconSet(
    Icons.star_outline_rounded,
    Icons.star_rounded,
    Icons.star_rounded,
  );

  /// Receipt.
  static const receipt = AppIconSet(
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
    Icons.receipt_long_rounded,
  );

  /// Dollar coin.
  static const currencyDollar = AppIconSet(
    Icons.attach_money_rounded,
    Icons.paid_rounded,
    Icons.paid_rounded,
  );

  /// Group of people.
  static const usersThree = AppIconSet(
    Icons.groups_outlined,
    Icons.groups_rounded,
    Icons.groups_rounded,
  );

  /// Chat bubble.
  static const chat = AppIconSet(
    Icons.chat_bubble_outline_rounded,
    Icons.chat_bubble_rounded,
    Icons.chat_bubble_rounded,
  );

  /// Play.
  static const play = AppIconSet(
    Icons.play_arrow_rounded,
    Icons.play_arrow_rounded,
    Icons.play_arrow_rounded,
  );

  /// Pause.
  static const pause = AppIconSet(
    Icons.pause_rounded,
    Icons.pause_rounded,
    Icons.pause_rounded,
  );

  /// Sign out.
  static const signOut = AppIconSet(
    Icons.logout_rounded,
    Icons.logout_rounded,
    Icons.logout_rounded,
  );

  /// Restart arrow.
  static const restart = AppIconSet(
    Icons.restart_alt_rounded,
    Icons.restart_alt_rounded,
    Icons.restart_alt_rounded,
  );

  /// Lightning bolt.
  static const lightning = AppIconSet(
    Icons.bolt_outlined,
    Icons.bolt_rounded,
    Icons.bolt_rounded,
  );

  /// Wrench.
  static const wrench = AppIconSet(
    Icons.build_outlined,
    Icons.build_rounded,
    Icons.build_rounded,
  );

  /// Paper plane (send).
  static const send = AppIconSet(
    Icons.send_outlined,
    Icons.send_rounded,
    Icons.send_rounded,
  );

  /// Trophy.
  static const trophy = AppIconSet(
    Icons.emoji_events_outlined,
    Icons.emoji_events_rounded,
    Icons.emoji_events_rounded,
  );

  /// Sparkle.
  static const sparkle = AppIconSet(
    Icons.auto_awesome_outlined,
    Icons.auto_awesome_rounded,
    Icons.auto_awesome_rounded,
  );

  /// Clock.
  static const clock = AppIconSet(
    Icons.schedule_outlined,
    Icons.schedule_rounded,
    Icons.schedule_rounded,
  );

  /// Arrow pointing right.
  static const arrowRight = AppIconSet(
    Icons.arrow_forward_rounded,
    Icons.arrow_forward_rounded,
    Icons.arrow_forward_rounded,
  );

  /// Check mark.
  static const check = AppIconSet(
    Icons.check_rounded,
    Icons.check_rounded,
    Icons.check_rounded,
  );
}

/// Renders an [AppIconSet] at a given weight.
class AppIcon extends StatelessWidget {
  /// Creates an icon.
  const AppIcon(
    this.icon, {
    this.style = AppIconStyle.regular,
    this.size = AppSizes.iconSmall,
    this.color,
    this.semanticLabel,
    super.key,
  });

  /// Which glyph.
  final AppIconSet icon;

  /// Which weight.
  final AppIconStyle style;

  /// Icon size.
  final double size;

  /// Color; defaults to the ambient icon theme.
  final Color? color;

  /// Accessibility label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon.resolve(style),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
