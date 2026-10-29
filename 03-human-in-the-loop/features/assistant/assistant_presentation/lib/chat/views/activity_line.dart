import 'package:app_ui/app_ui.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// A quiet line for a tool call of the agent that has no card of its own.
class ActivityLine extends StatelessWidget {
  const ActivityLine({required this.call, super.key});

  final ToolCallView call;

  @override
  Widget build(BuildContext context) {
    final label = switch (call.name) {
      'AGUISendStateDelta' || 'AGUISendStateSnapshot' => 'Updated the form',
      _ => null,
    };
    if (label == null) return const SizedBox.shrink();
    final p = context.palette;
    return Align(
      alignment: Alignment.centerLeft,
      child: AppChip(
        label: label,
        icon: AppIcons.wrench,
        foreground: p.onNavyMuted,
        background: p.onNavyFill,
      ),
    );
  }
}
