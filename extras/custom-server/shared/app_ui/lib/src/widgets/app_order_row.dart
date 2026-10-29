import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_pressable.dart';
import 'package:flutter/material.dart';

/// How urgent an order is, which drives the row's color and stripe.
enum AppUrgency {
  /// Nothing special.
  normal,

  /// Getting late.
  warn,

  /// Late: pulses red.
  urgent,

  /// Delivered successfully.
  done,
}

/// Board row for one order. Pass plain strings; map your model outside.
class AppOrderRow extends StatefulWidget {
  /// Creates an order row.
  const AppOrderRow({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.urgency = AppUrgency.normal,
    this.selected = false,
    this.unread = false,
    this.onTap,
    super.key,
  });

  /// Primary line, usually the customer name.
  final String title;

  /// Secondary line, usually the items.
  final String subtitle;

  /// Right-aligned text on the title line (e.g. a countdown).
  final String? trailing;

  /// Urgency level.
  final AppUrgency urgency;

  /// Whether the row shows the selection outline.
  final bool selected;

  /// Whether to show the unread-message icon.
  final bool unread;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  State<AppOrderRow> createState() => _AppOrderRowState();
}

class _AppOrderRowState extends State<AppOrderRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.urgent,
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(AppOrderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.urgency == AppUrgency.urgent) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (background, stripe) = switch (widget.urgency) {
      AppUrgency.normal => (p.cardGround, null),
      AppUrgency.warn => (p.warningWash, p.warning),
      AppUrgency.urgent => (p.negativeWash, p.negative),
      AppUrgency.done => (p.positiveWash, p.positive),
    };
    final done = widget.urgency == AppUrgency.done;
    return AppPressable(
      onTap: widget.onTap,
      pressedScale: 0.99,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final color = widget.urgency == AppUrgency.urgent
              ? Color.lerp(
                  background,
                  AppColors.negativeWashPulse,
                  _pulse.value,
                )!
              : background;
          return AnimatedContainer(
            duration: AppMotion.quick,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.rowBorder,
              border: Border.all(
                color: widget.selected ? p.accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: AppRadii.rowBorder,
          child: Stack(
            children: [
              if (stripe != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    key: const Key('appOrderRow_stripe'),
                    width: AppSizes.stripe,
                    color: stripe,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: p.ink,
                            ),
                          ),
                        ),
                        if (widget.unread) ...[
                          AppIcon(
                            AppIcons.chat,
                            style: AppIconStyle.fill,
                            size: 18,
                            color: p.accent,
                            semanticLabel: 'Unread message',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        if (done)
                          AppIcon(
                            AppIcons.checkCircle,
                            style: AppIconStyle.fill,
                            size: AppSizes.iconLarge,
                            color: p.positive,
                          )
                        else if (widget.trailing != null)
                          Text(
                            widget.trailing!,
                            style: AppTypography.mono.copyWith(
                              color: p.inkTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: done ? p.positive : p.inkSecondary,
                        fontWeight: done ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
