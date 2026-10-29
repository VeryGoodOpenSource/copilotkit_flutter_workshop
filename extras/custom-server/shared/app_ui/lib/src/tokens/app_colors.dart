import 'dart:ui';

/// Raw brand colors of the Very Good Coffee Manager.
///
/// These are theme-independent constants. Widgets should prefer the semantic
/// roles in `AppPalette`, which adapt to light and dark mode.
abstract final class AppColors {
  /// Deep navy used by the score bar, agent panel and dialog heroes.
  static const Color navy = Color(0xFF0C1A45);

  /// Lighter navy used for gradients and raised navy surfaces.
  static const Color navy2 = Color(0xFF16296B);

  /// Soft periwinkle used for fills on navy.
  static const Color sky = Color(0xFF8FA8FF);

  /// Primary brand blue.
  static const Color accent = Color(0xFF2A48DE);

  /// Light page ground.
  static const Color ground = Color(0xFFE9EDF8);

  /// Slightly lighter ground used for rows inside white cards.
  static const Color cardGround = Color(0xFFF1F4FB);

  /// White card surface.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text ink (warm near-black).
  static const Color ink = Color(0xFF191817);

  /// Positive / success green.
  static const Color positive = Color(0xFF1FA567);

  /// Negative / error red.
  static const Color negative = Color(0xFFE0353B);

  /// Warning amber (urgency stripe).
  static const Color warning = Color(0xFFF5A524);

  /// Burnt orange used for incident and urgent tags.
  static const Color incident = Color(0xFFC4551A);

  /// Background wash for a warning order row.
  static const Color warningWash = Color(0xFFFFF3D6);

  /// Background wash for an urgent order row.
  static const Color negativeWash = Color(0xFFFFE1E2);

  /// Pulse target of the urgent order row animation.
  static const Color negativeWashPulse = Color(0xFFFFD0D2);

  /// Background wash for a done order row.
  static const Color positiveWash = Color(0xFFD9F5E6);

  /// Background wash for a slow courier row.
  static const Color slowWash = Color(0xFFFFE9EA);

  /// Positive text color on navy.
  static const Color positiveOnNavy = Color(0xFF4FDC9A);

  /// Negative text color on navy.
  static const Color negativeOnNavy = Color(0xFFFF7B80);

  /// Warning text color on navy.
  static const Color warningOnNavy = Color(0xFFFFE08A);

  /// Stage color: order requested.
  static const Color stageRequested = Color(0xFF8FA8FF);

  /// Stage color: barista is preparing.
  static const Color stageBarista = Color(0xFF4F6EF0);

  /// Stage color: out for delivery.
  static const Color stageDelivery = Color(0xFF2A48DE);

  /// Stage color: delivered.
  static const Color stageDelivered = Color(0xFF1FA567);

  /// Dark mode page ground.
  static const Color darkGround = Color(0xFF070E26);

  /// Dark mode card surface.
  static const Color darkSurface = Color(0xFF111D4A);

  /// Dark mode inset ground for rows inside cards.
  static const Color darkCardGround = Color(0xFF1A2A63);

  /// Dark mode accent, lifted for contrast on navy.
  static const Color darkAccent = Color(0xFF7C93FF);

  /// Dark mode ink.
  static const Color darkInk = Color(0xFFF3F4F8);
}
