import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_pressable.dart';
import 'package:app_ui/src/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';

/// Card the copilot uses to ask the manager for a decision.
///
/// Compose it with [AppOptionTile]s and buttons as [children].
class AppDecisionCard extends StatelessWidget {
  /// Creates a decision card.
  const AppDecisionCard({
    required this.kindLabel,
    required this.title,
    required this.children,
    this.kindIcon,
    this.trailing,
    this.diagnosis,
    this.urgent = false,
    this.complete = false,
    this.loading = false,
    super.key,
  });

  /// Small label above the title (e.g. "Incident").
  final String kindLabel;

  /// Optional icon beside [kindLabel].
  final AppIconSet? kindIcon;

  /// Card title. Null while it is still arriving: see [loading].
  final String? title;

  /// Optional chip shown on the right of the header.
  final Widget? trailing;

  /// Optional explanatory paragraph. Null while it is still arriving: see
  /// [loading].
  final String? diagnosis;

  /// Warms the tag color and border (urgent category).
  final bool urgent;

  /// Flattens the card once the decision was made.
  final bool complete;

  /// Whether the card is still being written: a missing [title] or
  /// [diagnosis] shows as a skeleton line instead of being left out.
  final bool loading;

  /// Body widgets.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tagColor = urgent ? p.incident : p.accent;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3l),
      decoration: BoxDecoration(
        color: complete ? p.cardGround : p.surface,
        borderRadius: BorderRadius.circular(AppRadii.proposal),
        border: Border.all(
          color: complete
              ? Colors.transparent
              : (urgent ? p.incident.withValues(alpha: 0.35) : p.hairline),
        ),
        boxShadow: complete ? null : AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (kindIcon != null) ...[
                AppIcon(kindIcon!, style: AppIconStyle.fill, color: tagColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  kindLabel,
                  style: AppTypography.smallMedium.copyWith(color: tagColor),
                ),
              ),
              ?trailing,
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              title!,
              style: AppTypography.subtitle.copyWith(color: p.heading),
            ),
          ] else if (loading) ...[
            const SizedBox(height: AppSpacing.lg),
            const AppSkeleton(height: 20),
          ],
          if (diagnosis != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              diagnosis!,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: p.inkSecondary,
              ),
            ),
          ] else if (loading) ...[
            const SizedBox(height: AppSpacing.lg),
            const AppSkeleton(),
            const SizedBox(height: AppSpacing.sm),
            const FractionallySizedBox(widthFactor: 0.7, child: AppSkeleton()),
          ],
          for (final child in children) ...[
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ],
      ),
    );
  }
}

/// Selectable option inside an [AppDecisionCard].
class AppOptionTile extends StatelessWidget {
  /// Creates an option tile.
  const AppOptionTile({
    required this.label,
    this.detail,
    this.cost,
    this.recommended = false,
    this.recommendedLabel = 'Recommended',
    this.selected = false,
    this.onTap,
    super.key,
  });

  /// Option title.
  final String label;

  /// Optional description.
  final String? detail;

  /// Optional right-aligned cost text.
  final String? cost;

  /// Show the "Recommended" tag.
  final bool recommended;

  /// Text of the recommended tag.
  final String recommendedLabel;

  /// Whether the option is chosen.
  final bool selected;

  /// Tap callback; null makes the tile read-only.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(
      opacity: onTap == null && !selected ? 0.7 : 1,
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.99,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: selected ? p.accentWash : p.cardGround,
            borderRadius: BorderRadius.circular(AppRadii.option),
            border: Border.all(
              color: selected ? p.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommended)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: Text(
                    recommendedLabel.toUpperCase(),
                    style: AppTypography.tag.copyWith(color: p.accent),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.bodyMedium.copyWith(color: p.ink),
                    ),
                  ),
                  if (cost != null)
                    Text(
                      cost!,
                      style: AppTypography.small.copyWith(
                        color: p.inkSecondary,
                      ),
                    ),
                ],
              ),
              if (detail != null)
                Text(
                  detail!,
                  style: AppTypography.small.copyWith(color: p.inkTertiary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
