import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Thin progress bar with an optional target marker.
class AppProgressBar extends StatelessWidget {
  /// Creates a progress bar. [value] and [target] are fractions in 0..1.
  const AppProgressBar({
    required this.value,
    this.target,
    this.onNavy = false,
    this.low = false,
    super.key,
  });

  /// Filled fraction.
  final double value;

  /// Optional target marker position.
  final double? target;

  /// Restyle for navy surfaces.
  final bool onNavy;

  /// Paint the fill in the negative color (a courier below target).
  final bool low;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final track = onNavy ? p.onNavy.withValues(alpha: 0.16) : p.fill;
    final fill = low ? p.negative : (onNavy ? p.sky : p.accent);
    final marker = onNavy ? p.onNavy : p.heading.withValues(alpha: 0.5);
    return SizedBox(
      height: AppSizes.barMarkerHeight,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth;
          final clamped = value.clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: AppSizes.bar,
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: AppRadii.pillBorder,
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.progress,
                curve: AppMotion.ease,
                height: AppSizes.bar,
                width: width * clamped,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: AppRadii.pillBorder,
                ),
              ),
              if (target != null)
                Positioned(
                  left:
                      (width * target!.clamp(0.0, 1.0)) -
                      AppSizes.barMarker / 2,
                  child: Container(
                    key: const Key('appProgressBar_target'),
                    width: AppSizes.barMarker,
                    height: AppSizes.barMarkerHeight,
                    decoration: BoxDecoration(
                      color: marker,
                      borderRadius: BorderRadius.circular(AppSizes.barMarker),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
