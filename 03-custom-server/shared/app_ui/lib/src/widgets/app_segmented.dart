import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_button.dart';
import 'package:app_ui/src/widgets/app_pressable.dart';
import 'package:flutter/material.dart';

/// Pill-shaped segmented control (speed, difficulty, chat target...).
class AppSegmented<T> extends StatelessWidget {
  /// Creates a segmented control.
  const AppSegmented({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.onNavy = false,
    this.compact = false,
    super.key,
  });

  /// Selectable values mapped to their labels, in display order.
  final Map<T, String> segments;

  /// Currently selected value.
  final T value;

  /// Called with the tapped value; null disables the control.
  final ValueChanged<T>? onChanged;

  /// Restyle for navy surfaces.
  final bool onNavy;

  /// Tighter padding for mini panels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppOpacityWhen(
      dim: onChanged == null,
      opacity: 0.4,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs + 1),
        decoration: BoxDecoration(
          color: onNavy ? p.onNavyFill : p.fill,
          borderRadius: AppRadii.pillBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in segments.entries)
              _Segment(
                label: entry.value,
                selected: entry.key == value,
                onNavy: onNavy,
                compact: compact,
                onTap: onChanged == null ? null : () => onChanged!(entry.key),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onNavy,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool onNavy;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color background;
    final Color foreground;
    if (selected) {
      background = onNavy ? p.onNavy : p.surface;
      foreground = onNavy ? p.navy : p.ink;
    } else {
      background = Colors.transparent;
      foreground = onNavy ? p.onNavy.withValues(alpha: 0.78) : p.inkSecondary;
    }
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: AppMotion.quick,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.lg : AppSpacing.xxl,
          vertical: compact ? AppSpacing.sm - 1 : AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadii.pillBorder,
          boxShadow: selected && !onNavy ? AppElevation.segment : null,
        ),
        child: Text(
          label,
          style: (compact ? AppTypography.chip : AppTypography.smallMedium)
              .copyWith(color: foreground),
        ),
      ),
    );
  }
}
