import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/tokens/tokens.dart';
import 'package:app_ui/src/widgets/app_icons.dart';
import 'package:app_ui/src/widgets/app_pressable.dart';
import 'package:flutter/material.dart';

/// Who wrote a chat message.
enum AppChatRole {
  /// The customer: left aligned, neutral.
  customer,

  /// The courier: left aligned, accent wash.
  courier,

  /// The manager (the user): right aligned, navy or accent.
  manager,
}

/// Chat bubble. Customer and courier sit left, the manager sits right.
class AppChatBubble extends StatelessWidget {
  /// Creates a chat bubble.
  const AppChatBubble({
    required this.text,
    required this.role,
    this.timestamp,
    this.sender,
    this.onNavy = false,
    this.accent = false,
    super.key,
  });

  /// Message text.
  final String text;

  /// Author role.
  final AppChatRole role;

  /// Optional faded timestamp under the text.
  final String? timestamp;

  /// Optional sender name above the text.
  final String? sender;

  /// Restyle for navy surfaces (the agent panel).
  final bool onNavy;

  /// Use the accent color for manager bubbles instead of navy.
  final bool accent;

  static const double _smallCorner = 6;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mine = role == AppChatRole.manager;
    final Color background;
    final Color foreground;
    if (mine) {
      background = (accent || onNavy) ? p.accent : p.navy;
      foreground = onNavy || accent ? p.surface : p.onNavy;
    } else if (role == AppChatRole.courier) {
      background = onNavy ? p.onNavy.withValues(alpha: 0.2) : p.accentWash;
      foreground = onNavy ? p.onNavy : p.accent;
    } else {
      background = onNavy ? p.onNavyFill : p.cardGround;
      foreground = onNavy ? p.onNavy : p.ink;
    }
    const big = Radius.circular(20);
    const small = Radius.circular(_smallCorner);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: AppSizes.bubbleWidthFactor,
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.only(
                topLeft: big,
                topRight: big,
                bottomLeft: mine ? big : small,
                bottomRight: mine ? small : big,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sender != null)
                  Text(
                    sender!,
                    style: AppTypography.chip.copyWith(
                      color: foreground.withValues(alpha: 0.7),
                    ),
                  ),
                Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: foreground,
                    height: 1.45,
                  ),
                ),
                if (timestamp != null)
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      timestamp!,
                      style: AppTypography.micro.copyWith(color: foreground),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three bouncing dots shown while someone is typing.
class AppTypingBubble extends StatefulWidget {
  /// Creates a typing indicator.
  const AppTypingBubble({this.onNavy = false, super.key});

  /// Restyle for navy surfaces.
  final bool onNavy;

  @override
  State<AppTypingBubble> createState() => _AppTypingBubbleState();
}

class _AppTypingBubbleState extends State<AppTypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.typing,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = widget.onNavy ? p.onNavy : p.ink;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3l,
          vertical: AppSpacing.xxl - 1,
        ),
        decoration: BoxDecoration(
          color: widget.onNavy ? p.onNavyFill : p.cardGround,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xs + 1),
                  _dot(color, i),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dot(Color color, int index) {
    // Each dot is offset by 0.15 of the period, peaking at 30% of its cycle.
    final t = (_controller.value - index * 0.15) % 1.0;
    final peak = t < 0.3 ? t / 0.3 : (t < 0.6 ? (0.6 - t) / 0.3 : 0.0);
    return Transform.translate(
      offset: Offset(0, -3 * peak),
      child: Container(
        width: AppSizes.typingDot,
        height: AppSizes.typingDot,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3 + 0.7 * peak),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Pill text field with a send button.
class AppComposer extends StatefulWidget {
  /// Creates a composer.
  const AppComposer({
    required this.onSend,
    this.hint = 'Type a message',
    this.enabled = true,
    this.onNavy = false,
    this.compact = false,
    super.key,
  });

  /// Called with the trimmed text when sent. Empty text is ignored.
  final ValueChanged<String> onSend;

  /// Placeholder text.
  final String hint;

  /// Whether input is enabled.
  final bool enabled;

  /// Restyle for navy surfaces.
  final bool onNavy;

  /// Smaller control height.
  final bool compact;

  @override
  State<AppComposer> createState() => _AppComposerState();
}

class _AppComposerState extends State<AppComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit([String? _]) {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final height = widget.compact ? AppSizes.controlCompact : AppSizes.control;
    final fg = widget.onNavy ? p.onNavy : p.ink;
    final fillColor = widget.onNavy ? p.onNavyFill : p.fill;
    final focus = widget.onNavy ? p.sky : p.ink;
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
      borderRadius: AppRadii.pillBorder,
      borderSide: BorderSide(color: c, width: w),
    );
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              onSubmitted: _submit,
              style: AppTypography.body.copyWith(color: fg),
              cursorColor: fg,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.body.copyWith(
                  color: widget.onNavy ? p.onNavyMuted : p.inkTertiary,
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4l - 2,
                ),
                border: border(Colors.transparent, 0),
                enabledBorder: border(Colors.transparent, 0),
                disabledBorder: border(Colors.transparent, 0),
                focusedBorder: border(focus, 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AppPressable(
          onTap: widget.enabled ? _submit : null,
          semanticLabel: 'Send',
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: widget.onNavy ? p.onNavyFill : p.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(
              AppIcons.send,
              style: AppIconStyle.fill,
              color: widget.onNavy ? p.onNavy : p.surface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Suggestion pill shown above the composer on navy.
class AppSuggestionChip extends StatelessWidget {
  /// Creates a suggestion chip.
  const AppSuggestionChip({
    required this.label,
    required this.onTap,
    this.onNavy = true,
    super.key,
  });

  /// Suggestion text.
  final String label;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Restyle for navy surfaces.
  final bool onNavy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppPressable(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onNavy ? p.onNavy.withValues(alpha: 0.12) : p.fill,
          borderRadius: AppRadii.pillBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: AppTypography.micro.copyWith(
              color: onNavy ? p.onNavy : p.ink,
            ),
          ),
        ),
      ),
    );
  }
}
