import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds with the [CalaveritaDraft] in the agent's shared state, and only
/// when it changes.
///
/// The form lives in the shared state: the agent changes it with state
/// updates and the app changes it with `DraftEdits`. Nothing else holds a
/// copy, so the details, the stage and the agent all see the same draft.
/// Needs a `CopilotAgentScope` above it.
class SharedDraft extends StatelessWidget {
  const SharedDraft({required this.builder, super.key});

  final Widget Function(BuildContext context, CalaveritaDraft draft) builder;

  @override
  Widget build(BuildContext context) {
    return AgentStateBuilder<CalaveritaDraft>(
      selector: draftOf,
      builder: builder,
    );
  }

  /// The draft in [state], or an empty one while the agent shares nothing.
  static CalaveritaDraft draftOf(CopilotAgentState state) =>
      state.sharedState?.decode(CalaveritaDraft.fromJson) ??
      const CalaveritaDraft();
}
