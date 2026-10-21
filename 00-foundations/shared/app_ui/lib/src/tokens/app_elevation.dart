import 'package:flutter/painting.dart';

/// Shadow tokens.
abstract final class AppElevation {
  /// Soft shadow under cards, panels and primary buttons.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D0C1A45), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x140C1A45), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Heavy shadow under the welcome dialog.
  static const List<BoxShadow> dialog = [
    BoxShadow(color: Color(0x660C1A45), blurRadius: 80, offset: Offset(0, 24)),
  ];

  /// Shadow under the selected segment of a segmented control.
  static const List<BoxShadow> segment = [
    BoxShadow(color: Color(0x1F191817), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Shadow under the primary icon button.
  static const List<BoxShadow> iconButton = [
    BoxShadow(color: Color(0x330C1A45), blurRadius: 14, offset: Offset(0, 4)),
  ];

  /// Scrim color behind plain dialogs.
  static const Color scrim = Color(0x66191817);

  /// Scrim color behind branded dialogs.
  static const Color brandScrim = Color(0x8C0C1A45);

  /// Scrim color behind result dialogs.
  static const Color resultScrim = Color(0x990C1A45);

  /// Blur sigma behind branded dialogs.
  static const double scrimBlur = 4;
}
