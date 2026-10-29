import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/shared_draft.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/widgets.dart';

/// What the person does to the form. Each edit patches the shared state, so
/// the next run of the agent receives it and the agent always sees what the
/// person changed.
class DraftEdits {
  const DraftEdits._(this._agent);

  /// The edits of the agent of the nearest `CopilotAgentScope`.
  factory DraftEdits.of(BuildContext context) =>
      DraftEdits._(CopilotAgentScope.of(context));

  final CopilotAgent _agent;

  CalaveritaDraft get _draft => SharedDraft.draftOf(_agent.state);

  /// Shares the empty form if nothing is shared yet.
  ///
  /// The agent only sees state that is not empty, so the form has to be
  /// there before the first message.
  void ensureInitialized() {
    if (_agent.state.sharedState == null) reset();
  }

  /// Clears the form.
  void reset() =>
      _agent.setSharedState(SharedState(const CalaveritaDraft().toJson()));

  void nameChanged(String name) => _set('/name', name);

  void jobChanged(String job) => _set('/job', job);

  void toneChanged(Tone tone) => _set('/tone', tone.name);

  void skullPartChanged(SkullPart part, String variant) =>
      _set('/skull/${part.name}', variant);

  void skullColorChanged(String color) => _set('/skull/color', color);

  void _set(String path, String value) {
    final operations = [StatePatchAdd(path: path, value: value)];
    try {
      _agent.patchSharedState(operations);
    } on FormatException {
      // The agent replaced the state with one that lacks this path. Start
      // again from the form as we can read it, which has every path.
      _agent.setSharedState(SharedState(_draft.toJson()));
      _agent.patchSharedState(operations);
    }
  }
}
