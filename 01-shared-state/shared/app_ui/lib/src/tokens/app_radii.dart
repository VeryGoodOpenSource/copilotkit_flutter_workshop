import 'package:flutter/painting.dart';

/// Corner radii.
abstract final class AppRadii {
  /// Radius of cards and panels.
  static const double card = 28;

  /// Radius of dialogs with a hero.
  static const double dialog = 32;

  /// Radius of a nested decision card.
  static const double proposal = 24;

  /// Radius of order rows and nested blocks.
  static const double row = 18;

  /// Radius of options and person rows.
  static const double option = 16;

  /// Radius of small chips and text fields.
  static const double chip = 14;

  /// Radius of tiny elements (skeleton lines).
  static const double tiny = 6;

  /// Radius large enough to make any box a pill.
  static const double pill = 999;

  /// Pill border radius.
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
  );

  /// Card border radius.
  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );

  /// Row border radius.
  static const BorderRadius rowBorder = BorderRadius.all(Radius.circular(row));

  /// Chip border radius.
  static const BorderRadius chipBorder = BorderRadius.all(
    Radius.circular(chip),
  );
}
