import 'dart:ui';

import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_button.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_tone.dart';
import 'package:flutter/material.dart';

/// Shows [builder] as a modal overlay with the design system scrim.
///
/// Set [branded] for the navy blurred scrim used by welcome and result
/// dialogs.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool branded = true,
  bool dismissible = false,
}) {
  final p = context.palette;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Dismiss',
    barrierColor: branded ? AppElevation.brandScrim : p.scrim,
    transitionDuration: AppMotion.enter,
    pageBuilder: (context, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3l),
          child: builder(context),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.ease);
      Widget result = FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
      if (branded) {
        result = BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppElevation.scrimBlur * animation.value,
            sigmaY: AppElevation.scrimBlur * animation.value,
          ),
          child: result,
        );
      }
      return result;
    },
  );
}

/// Dialog frame: rounded surface, optional navy [hero] and a padded body.
class AppDialogScaffold extends StatelessWidget {
  /// Creates a dialog scaffold.
  const AppDialogScaffold({
    required this.children,
    this.hero,
    this.maxWidth = AppSizes.dialogWidth,
    this.radius = AppRadii.card,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(AppSpacing.x6l),
    super.key,
  });

  /// Optional hero shown above the body on navy.
  final Widget? hero;

  /// Body children, separated by 14px.
  final List<Widget> children;

  /// Maximum dialog width.
  final double maxWidth;

  /// Corner radius.
  final double radius;

  /// Cross axis alignment of the body.
  final CrossAxisAlignment crossAxisAlignment;

  /// Body padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: hero == null ? AppElevation.card : AppElevation.dialog,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?hero,
                  Padding(
                    padding: padding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: crossAxisAlignment,
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.xxl),
                          children[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Welcome dialog: navy hero with brand, then title, copy and actions.
class AppWelcomeDialog extends StatelessWidget {
  /// Creates a welcome dialog.
  const AppWelcomeDialog({
    required this.hero,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.brand,
    this.paragraphs = const [],
    this.steps = const [],
    this.goals = const [],
    this.footnote,
    super.key,
  });

  /// Hero artwork, usually an `AppUnicorn`.
  final Widget hero;

  /// Brand line under the artwork.
  final String? brand;

  /// Dialog headline.
  final String title;

  /// Body paragraphs.
  final List<String> paragraphs;

  /// Numbered-style steps rendered as inset rows.
  final List<Widget> steps;

  /// Goal chips (see `AppGoalChip`).
  final List<Widget> goals;

  /// Muted note above the action.
  final String? footnote;

  /// Label of the big action button.
  final String actionLabel;

  /// Action callback.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppDialogScaffold(
      maxWidth: AppSizes.welcomeWidth,
      radius: AppRadii.dialog,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x7l,
        AppSpacing.x5l,
        AppSpacing.x7l,
        AppSpacing.x7l,
      ),
      hero: Container(
        color: p.navy,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x5l,
          AppSpacing.x6l,
          AppSpacing.x5l,
          AppSpacing.x4l,
        ),
        child: Column(
          children: [
            hero,
            if (brand != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                brand!,
                style: AppTypography.brand.copyWith(
                  color: p.onNavy,
                  fontSize: 24,
                ),
              ),
            ],
          ],
        ),
      ),
      children: [
        Text(title, style: AppTypography.headline.copyWith(color: p.heading)),
        for (final text in paragraphs)
          Text(
            text,
            style: AppTypography.bodyLarge.copyWith(color: p.inkSecondary),
          ),
        if (steps.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                steps[i],
              ],
            ],
          ),
        if (goals.isNotEmpty)
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: goals,
          ),
        if (footnote != null)
          Text(
            footnote!,
            style: AppTypography.bodyLarge.copyWith(color: p.inkTertiary),
          ),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: actionLabel,
            onPressed: onAction,
            size: AppButtonSize.big,
            expanded: true,
          ),
        ),
      ],
    );
  }
}

/// Inset step row for [AppWelcomeDialog.steps].
class AppDialogStep extends StatelessWidget {
  /// Creates a step row with an optional bold [strong] prefix.
  const AppDialogStep({required this.text, this.strong, super.key});

  /// Regular text.
  final String text;

  /// Bold lead-in.
  final String? strong;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.cardGround,
        borderRadius: AppRadii.chipBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              if (strong != null)
                TextSpan(
                  text: '$strong ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: p.heading,
                  ),
                ),
              TextSpan(text: text),
            ],
          ),
          style: AppTypography.body.copyWith(color: p.inkSecondary),
        ),
      ),
    );
  }
}

/// Result dialog: big icon, headline, message, check rows and actions.
class AppResultDialog extends StatelessWidget {
  /// Creates a result dialog.
  const AppResultDialog({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.won = true,
    this.message,
    this.checks = const [],
    this.extra,
    super.key,
  });

  /// Whether the outcome was a win (green check) or a loss (red cross).
  final bool won;

  /// Headline.
  final String title;

  /// Optional paragraph.
  final String? message;

  /// Check rows, typically `AppKeyValueRow`s.
  final List<Widget> checks;

  /// Optional extra block under the checks (e.g. a week summary).
  final Widget? extra;

  /// Primary action label.
  final String actionLabel;

  /// Primary action callback.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = won ? AppTone.positive : AppTone.negative;
    return AppDialogScaffold(
      maxWidth: AppSizes.resultWidth,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppIcon(
          won ? AppIcons.trophy : AppIcons.xCircle,
          style: AppIconStyle.fill,
          size: AppSizes.iconHero,
          color: tone.foreground(p),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(color: p.heading),
        ),
        if (message != null)
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: p.inkSecondary,
            ),
          ),
        if (checks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < checks.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                checks[i],
              ],
            ],
          ),
        ?extra,
        AppButton(
          label: actionLabel,
          onPressed: onAction,
          icon: AppIcons.restart,
        ),
      ],
    );
  }
}
