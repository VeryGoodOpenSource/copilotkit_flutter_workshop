import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_tone.dart';
import 'package:flutter/material.dart';

/// Small rounded label, the base of every status pill.
class AppChip extends StatelessWidget {
  /// Creates a chip.
  const AppChip({
    required this.label,
    this.tone = AppTone.neutral,
    this.icon,
    this.foreground,
    this.background,
    super.key,
  });

  /// Text of the chip.
  final String label;

  /// Semantic tone that picks the colors.
  final AppTone tone;

  /// Optional leading icon.
  final AppIconSet? icon;

  /// Overrides the tone's foreground.
  final Color? foreground;

  /// Overrides the tone's background.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = foreground ?? tone.foreground(p);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? tone.background(p),
        borderRadius: AppRadii.chipBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxs + 1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, style: AppIconStyle.fill, size: 13, color: fg),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: AppTypography.chip.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

/// How the copilot judges a decision.
enum AppVerdict {
  /// Approved as proposed.
  approve,

  /// Approved with edits.
  edit,

  /// Rejected.
  reject,
}

/// Chip for an [AppVerdict].
class AppVerdictChip extends StatelessWidget {
  /// Creates a verdict chip.
  const AppVerdictChip({required this.verdict, this.label, super.key});

  /// The verdict to show.
  final AppVerdict verdict;

  /// Overrides the default label ("Approved", "Edited", "Rejected").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (tone, text) = switch (verdict) {
      AppVerdict.approve => (AppTone.positive, 'Approved'),
      AppVerdict.edit => (AppTone.accent, 'Edited'),
      AppVerdict.reject => (AppTone.negative, 'Rejected'),
    };
    return AppChip(label: label ?? text, tone: tone);
  }
}

/// Severity of an incident.
enum AppSeverity {
  /// Needs action now.
  high,

  /// Needs attention.
  medium,

  /// Informational.
  low,
}

/// Chip for an [AppSeverity].
class AppSeverityChip extends StatelessWidget {
  /// Creates a severity chip.
  const AppSeverityChip({required this.severity, this.label, super.key});

  /// The severity to show.
  final AppSeverity severity;

  /// Overrides the default label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (tone, text) = switch (severity) {
      AppSeverity.high => (AppTone.negative, 'High'),
      AppSeverity.medium => (AppTone.accent, 'Medium'),
      AppSeverity.low => (AppTone.accent, 'Low'),
    };
    return AppChip(label: label ?? text, tone: tone);
  }
}

/// Rounded count bubble used in column headers.
class AppCountBadge extends StatelessWidget {
  /// Creates a count badge.
  const AppCountBadge({required this.count, super.key});

  /// Number shown.
  final int count;

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
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          '$count',
          style: AppTypography.smallMedium.copyWith(color: p.accent),
        ),
      ),
    );
  }
}

/// Stage of an order on the board.
enum AppStage {
  /// Customer requested it.
  requested,

  /// Barista is preparing it.
  barista,

  /// Courier is delivering it.
  delivery,

  /// Delivered.
  delivered,
}

/// Colored dot identifying an [AppStage].
class AppStageDot extends StatelessWidget {
  /// Creates a stage dot.
  const AppStageDot({required this.stage, super.key});

  /// Stage to color the dot for.
  final AppStage stage;

  /// Color of [stage].
  static Color colorOf(AppStage stage) => switch (stage) {
    AppStage.requested => AppColors.stageRequested,
    AppStage.barista => AppColors.stageBarista,
    AppStage.delivery => AppColors.stageDelivery,
    AppStage.delivered => AppColors.stageDelivered,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.dot,
      height: AppSizes.dot,
      decoration: BoxDecoration(color: colorOf(stage), shape: BoxShape.circle),
    );
  }
}

/// Progress state of an [AppStepPill].
enum AppStepState {
  /// Already completed.
  past,

  /// Current step.
  now,

  /// Not reached yet.
  upcoming,
}

/// Numbered pill of the day tracker, shown on navy.
class AppStepPill extends StatelessWidget {
  /// Creates a step pill.
  const AppStepPill({
    required this.number,
    required this.label,
    required this.state,
    super.key,
  });

  /// Step number.
  final int number;

  /// Step label.
  final String label;

  /// Progress state.
  final AppStepState state;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (background, foreground, badge, badgeText) = switch (state) {
      AppStepState.now => (p.onNavy, p.navy, p.accent, p.onNavy),
      AppStepState.past => (
        p.onNavy.withValues(alpha: 0.1),
        AppColors.positiveOnNavy,
        Colors.transparent,
        AppColors.positiveOnNavy,
      ),
      AppStepState.upcoming => (
        p.onNavy.withValues(alpha: 0.1),
        p.onNavyMuted,
        p.onNavy.withValues(alpha: 0.16),
        p.onNavyMuted,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xxs + 1,
          AppSpacing.md,
          AppSpacing.xxs + 1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.stepBadge,
              height: AppSizes.stepBadge,
              decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: state == AppStepState.past
                  ? AppIcon(
                      AppIcons.check,
                      style: AppIconStyle.fill,
                      size: 12,
                      color: badgeText,
                    )
                  : Text(
                      '$number',
                      style: AppTypography.tag.copyWith(
                        color: badgeText,
                        letterSpacing: 0,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm - 1),
            Text(label, style: AppTypography.chip.copyWith(color: foreground)),
          ],
        ),
      ),
    );
  }
}
