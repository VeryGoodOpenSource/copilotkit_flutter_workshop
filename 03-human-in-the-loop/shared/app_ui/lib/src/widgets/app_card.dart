import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:flutter/material.dart';

/// White rounded surface with the design system shadow.
class AppCard extends StatelessWidget {
  /// Creates a card.
  const AppCard({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.color,
    this.radius = AppRadii.card,
    this.shadow = true,
    this.clip = true,
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Background; defaults to the palette surface.
  final Color? color;

  /// Corner radius.
  final double radius;

  /// Whether to paint the card shadow.
  final bool shadow;

  /// Whether to clip children to the rounded rectangle.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? AppElevation.card : null,
      ),
      child: ClipRRect(
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Section title row: optional icon, title and trailing widget.
class AppSectionHeader extends StatelessWidget {
  /// Creates a section header.
  const AppSectionHeader({
    required this.title,
    this.icon,
    this.trailing,
    this.onNavy = false,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.x4l,
      AppSpacing.x3l,
      AppSpacing.x4l,
      AppSpacing.md,
    ),
    super.key,
  });

  /// Title text.
  final String title;

  /// Optional leading icon, drawn duotone in the accent color.
  final AppIconSet? icon;

  /// Optional trailing widget (count badge, chip, hint).
  final Widget? trailing;

  /// Restyle for navy surfaces.
  final bool onNavy;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = onNavy ? p.onNavy : p.heading;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            AppIcon(
              icon!,
              style: AppIconStyle.duotone,
              color: onNavy ? p.onNavy : p.accent,
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(color: color),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Titled card. The navy variant is used by the agent panel.
class AppPanel extends StatelessWidget {
  /// Creates a panel.
  const AppPanel({
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.navy = false,
    super.key,
  });

  /// Panel title.
  final String title;

  /// Panel body.
  final Widget child;

  /// Optional header icon.
  final AppIconSet? icon;

  /// Optional header trailing widget.
  final Widget? trailing;

  /// Whether the panel is drawn on the navy background.
  final bool navy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      color: navy ? p.navy : p.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: title,
            icon: icon,
            trailing: trailing,
            onNavy: navy,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
