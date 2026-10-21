import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Pulsing placeholder line shown while the agent is thinking.
class AppSkeleton extends StatefulWidget {
  /// Creates a skeleton line of fixed [width], or full width when null.
  const AppSkeleton({this.width, this.height = 12, super.key});

  /// Width in logical pixels, or null to fill the parent.
  final double? width;

  /// Line height.
  final double height;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
  )..repeat(reverse: true);

  static const double _minOpacity = 0.4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: _minOpacity).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: p.fill,
          borderRadius: BorderRadius.circular(AppRadii.tiny),
        ),
      ),
    );
  }
}

/// Stack of skeleton lines (a "40px / 60% / 90%" loading block).
class AppSkeletonBlock extends StatelessWidget {
  /// Creates a block of skeleton lines.
  const AppSkeletonBlock({this.fractions = const [0.4, 0.9, 0.6], super.key});

  /// Width of each line as a fraction of the available width.
  final List<double> fractions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in fractions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: FractionallySizedBox(
              widthFactor: f,
              child: const AppSkeleton(),
            ),
          ),
      ],
    );
  }
}
