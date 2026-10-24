import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Floating pill banner, e.g. "Day 2 begins".
class AppToast extends StatelessWidget {
  /// Creates a toast.
  const AppToast({required this.message, super.key});

  /// Message shown.
  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.enter,
      curve: AppMotion.ease,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * AppSpacing.sm),
          child: child,
        ),
      ),
      child: Semantics(
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: AppRadii.pillBorder,
            boxShadow: AppElevation.card,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4l,
              vertical: AppSpacing.md,
            ),
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: p.heading),
            ),
          ),
        ),
      ),
    );
  }
}
