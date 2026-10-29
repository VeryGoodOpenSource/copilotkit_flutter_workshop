import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_progress.dart';
import 'package:flutter/material.dart';

/// Round avatar showing initials.
class AppAvatar extends StatelessWidget {
  /// Creates an avatar from a [name]; the first letter is shown.
  const AppAvatar({required this.name, this.alert = false, super.key});

  /// Name to take the initial from.
  final String name;

  /// Paint in the negative color.
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      decoration: BoxDecoration(
        color: alert ? p.negative : p.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.bodyMedium.copyWith(
          color: p.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Staff row: avatar, name, caption, meter and a trailing load figure.
class AppPersonRow extends StatelessWidget {
  /// Creates a person row.
  const AppPersonRow({
    required this.name,
    required this.caption,
    required this.meter,
    this.trailing,
    this.alert = false,
    this.meterTarget,
    super.key,
  });

  /// Person name.
  final String name;

  /// Right-aligned caption on the name line.
  final String caption;

  /// Meter fraction (0..1).
  final double meter;

  /// Optional target marker on the meter.
  final double? meterTarget;

  /// Trailing text (e.g. current load).
  final String? trailing;

  /// Highlights a slow or struggling person.
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: alert ? p.slowWash : p.cardGround,
        borderRadius: BorderRadius.circular(AppRadii.option),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            AppAvatar(name: name, alert: alert),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: p.ink,
                          ),
                        ),
                      ),
                      Text(
                        caption,
                        style: AppTypography.small.copyWith(
                          color: p.inkTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppProgressBar(value: meter, target: meterTarget, low: alert),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.lg),
              Text(
                trailing!,
                style: AppTypography.mono.copyWith(color: p.inkSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
