import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_progress.dart';
import 'package:app_ui/src/widgets/app_tone.dart';
import 'package:flutter/material.dart';

/// Score tile: caption, big value, optional suffix and progress bar.
class AppStatTile extends StatelessWidget {
  /// Creates a stat tile.
  const AppStatTile({
    required this.label,
    required this.value,
    this.suffix,
    this.tone = AppTone.neutral,
    this.progress,
    this.target,
    this.onNavy = true,
    this.mono = true,
    super.key,
  });

  /// Caption above the value.
  final String label;

  /// Main value text.
  final String value;

  /// Muted text after the value (e.g. "/ 30").
  final String? suffix;

  /// Tone of the value. Neutral uses the surface's primary color.
  final AppTone tone;

  /// Optional progress fraction (0..1) drawn below.
  final double? progress;

  /// Optional target marker fraction (0..1).
  final double? target;

  /// Whether the tile sits on navy (default) or on a light surface.
  final bool onNavy;

  /// Whether the value uses tabular monospace figures.
  final bool mono;

  Color _valueColor(AppPalette p) {
    if (onNavy) {
      return switch (tone) {
        AppTone.neutral => p.onNavy,
        AppTone.accent => p.sky,
        AppTone.positive => AppColors.positiveOnNavy,
        AppTone.warning => AppColors.warningOnNavy,
        AppTone.negative => AppColors.negativeOnNavy,
      };
    }
    return tone == AppTone.neutral ? p.heading : tone.foreground(p);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final muted = onNavy ? p.onNavyMuted : p.inkTertiary;
    final valueStyle =
        (mono
                ? AppTypography.mono.copyWith(
                    fontSize: AppTypography.big.fontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: AppTypography.big.letterSpacing,
                  )
                : AppTypography.big)
            .copyWith(color: _valueColor(p));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.small.copyWith(color: muted)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: valueStyle),
            if (suffix != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(suffix!, style: AppTypography.mono.copyWith(color: muted)),
            ],
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppProgressBar(value: progress!, target: target, onNavy: onNavy),
        ],
      ],
    );
  }
}

/// Goal chip: a bold figure with a label, on an accent wash.
class AppGoalChip extends StatelessWidget {
  /// Creates a goal chip, e.g. `AppGoalChip(strong: '30', label: 'orders')`.
  const AppGoalChip({required this.strong, required this.label, super.key});

  /// Bold part.
  final String strong;

  /// Regular part.
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.accentWash,
        borderRadius: AppRadii.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: strong,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: ' $label'),
            ],
          ),
          style: AppTypography.body.copyWith(color: p.accent, fontSize: 13),
        ),
      ),
    );
  }
}

/// Label on the left, value on the right, on an inset rounded row.
class AppKeyValueRow extends StatelessWidget {
  /// Creates a key-value row.
  const AppKeyValueRow({
    required this.label,
    required this.value,
    this.valueTone = AppTone.neutral,
    this.inset = true,
    this.mono = false,
    super.key,
  });

  /// Left text.
  final String label;

  /// Right text.
  final String value;

  /// Tone of the value.
  final AppTone valueTone;

  /// Whether the row has the inset card-ground background.
  final bool inset;

  /// Whether the value uses tabular monospace figures.
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final valueColor = valueTone == AppTone.neutral
        ? p.ink
        : valueTone.foreground(p);
    final base = mono
        ? AppTypography.mono.copyWith(fontSize: 14)
        : AppTypography.bodyMedium;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inset ? p.cardGround : null,
        borderRadius: AppRadii.rowBorder,
      ),
      child: Padding(
        padding: inset
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3l,
                vertical: AppSpacing.xl,
              )
            : const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: p.inkSecondary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(value, style: base.copyWith(color: valueColor)),
          ],
        ),
      ),
    );
  }
}
