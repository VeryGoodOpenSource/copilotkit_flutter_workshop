import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_pressable.dart';
import 'package:flutter/material.dart';

/// Visual variants of [AppButton].
enum AppButtonVariant {
  /// Solid brand blue.
  primary,

  /// Subtle fill.
  ghost,
}

/// Size presets of [AppButton].
enum AppButtonSize {
  /// 44px tall.
  regular,

  /// 52px tall with a larger label.
  big,

  /// 36px tall, for mini panels.
  compact,
}

/// Pill button of the design system.
class AppButton extends StatelessWidget {
  /// Creates a button.
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.onNavy = false,
    this.expanded = false,
    super.key,
  });

  /// Solid brand button.
  const AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    AppIconSet? icon,
    AppButtonSize size = AppButtonSize.regular,
    bool onNavy = false,
    bool expanded = false,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         icon: icon,
         size: size,
         onNavy: onNavy,
         expanded: expanded,
         key: key,
       );

  /// Subtle button.
  const AppButton.ghost({
    required String label,
    required VoidCallback? onPressed,
    AppIconSet? icon,
    AppButtonSize size = AppButtonSize.regular,
    bool onNavy = false,
    bool expanded = false,
    Key? key,
  }) : this(
         label: label,
         onPressed: onPressed,
         icon: icon,
         size: size,
         onNavy: onNavy,
         expanded: expanded,
         variant: AppButtonVariant.ghost,
         key: key,
       );

  /// Text shown on the button.
  final String label;

  /// Tap callback; null disables the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final AppButtonVariant variant;

  /// Size preset.
  final AppButtonSize size;

  /// Optional leading icon.
  final AppIconSet? icon;

  /// Restyle for placement on a navy surface.
  final bool onNavy;

  /// Whether the button fills the available width.
  final bool expanded;

  static const double _disabledOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final primary = variant == AppButtonVariant.primary;
    final Color background;
    final Color foreground;
    if (onNavy) {
      background = primary ? p.onNavy : p.onNavyFill;
      foreground = primary ? p.navy : p.onNavy;
    } else {
      background = primary ? p.accent : p.fill;
      foreground = primary ? p.surface : p.ink;
    }
    final (height, style) = switch (size) {
      AppButtonSize.regular => (AppSizes.control, AppTypography.button),
      AppButtonSize.big => (AppSizes.controlBig, AppTypography.buttonBig),
      AppButtonSize.compact => (AppSizes.controlCompact, AppTypography.button),
    };
    final shadow = primary && !onNavy ? AppElevation.card : null;
    return AppOpacityWhen(
      dim: onPressed == null,
      opacity: _disabledOpacity,
      child: AppPressable(
        onTap: onPressed,
        semanticLabel: label,
        child: Container(
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4l),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadii.pillBorder,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AppIcon(icon!, style: AppIconStyle.fill, color: foreground),
                const SizedBox(width: AppSpacing.md),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades its child when [dim] is true.
class AppOpacityWhen extends StatelessWidget {
  /// Creates the wrapper.
  const AppOpacityWhen({
    required this.dim,
    required this.opacity,
    required this.child,
    super.key,
  });

  /// Whether to apply [opacity].
  final bool dim;

  /// Opacity applied when dimmed.
  final double opacity;

  /// Content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: dim ? opacity : 1, child: child);
  }
}

/// Round icon-only button, used for play, pause and restart.
class AppIconButton extends StatelessWidget {
  /// Creates an icon button.
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.primary = false,
    this.onNavy = true,
    this.style = AppIconStyle.regular,
    super.key,
  });

  /// Glyph.
  final AppIconSet icon;

  /// Tap callback; null disables it.
  final VoidCallback? onPressed;

  /// Accessibility label.
  final String semanticLabel;

  /// Highlighted variant (white disc, brand icon).
  final bool primary;

  /// Whether it sits on navy (default) or on a light surface.
  final bool onNavy;

  /// Glyph weight.
  final AppIconStyle style;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final side = primary ? AppSizes.iconButtonPrimary : AppSizes.iconButton;
    final background = primary
        ? (onNavy ? p.onNavy : p.accent)
        : (onNavy ? p.onNavyFill : p.fill);
    final foreground = primary
        ? (onNavy ? p.accent : p.surface)
        : (onNavy ? p.onNavy : p.ink);
    return AppOpacityWhen(
      dim: onPressed == null,
      opacity: 0.4,
      child: AppPressable(
        onTap: onPressed,
        semanticLabel: semanticLabel,
        pressedScale: 0.92,
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: primary ? AppElevation.iconButton : null,
          ),
          alignment: Alignment.center,
          child: AppIcon(
            icon,
            style: style,
            size: AppSizes.icon,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
