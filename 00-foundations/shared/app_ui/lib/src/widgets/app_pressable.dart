import 'package:app_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// Scale-on-press and pointer cursor wrapper used by tappable widgets.
class AppPressable extends StatefulWidget {
  /// Creates a pressable area. A null [onTap] renders it inert.
  const AppPressable({
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.pressedScale = 0.96,
    super.key,
  });

  /// Content.
  final Widget child;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Optional accessibility label.
  final String? semanticLabel;

  /// Scale applied while pressed.
  final double pressedScale;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _down = false;

  void _set({required bool down}) {
    if (widget.onTap != null) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _set(down: true),
          onTapUp: (_) => _set(down: false),
          onTapCancel: () => _set(down: false),
          child: AnimatedScale(
            scale: _down ? widget.pressedScale : 1,
            duration: AppMotion.press,
            curve: AppMotion.ease,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
