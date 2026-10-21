import 'package:flutter/animation.dart';

/// Durations and curves.
abstract final class AppMotion {
  /// Press feedback.
  static const Duration press = Duration(milliseconds: 120);

  /// Hover / outline transitions.
  static const Duration quick = Duration(milliseconds: 200);

  /// Entrance animations.
  static const Duration enter = Duration(milliseconds: 400);

  /// Progress bar fills.
  static const Duration progress = Duration(milliseconds: 400);

  /// Skeleton pulse period.
  static const Duration pulse = Duration(milliseconds: 1200);

  /// Typing indicator period.
  static const Duration typing = Duration(milliseconds: 1100);

  /// Urgent pulse period.
  static const Duration urgent = Duration(milliseconds: 1600);

  /// The design system's ease curve, `cubic-bezier(0.2, 0.8, 0.2, 1)`.
  static const Curve ease = Cubic(0.2, 0.8, 0.2, 1);
}
