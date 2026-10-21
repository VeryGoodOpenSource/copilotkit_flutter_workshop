import 'dart:convert';

import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_args.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// Runs the `showCalaverita` tool: puts the verse the agent wrote together
/// with the form and the skull as they are right now.
class ShowCalaveritaHandler {
  const ShowCalaveritaHandler({required CalaveritaDraft Function() readDraft})
    : _readDraft = readDraft;

  final CalaveritaDraft Function() _readDraft;

  /// Returns the calaverita as JSON, or a sentence saying what is missing.
  ///
  /// The card of the tool shows the result, and the agent gets it back too.
  Future<String> handle(
    ShowCalaveritaArgs args, {
    required CancellationSignal signal,
  }) async {
    final draft = _readDraft();
    if (!draft.isComplete) {
      return 'The form still needs a name and a job, so nothing was shown.';
    }
    if (args.lines.isEmpty) return 'There was no verse to show.';
    return jsonEncode(
      Calaverita(
        name: draft.name.trim(),
        job: draft.job.trim().toLowerCase(),
        tone: draft.tone,
        lines: args.lines,
        skull: draft.skull,
      ).toJson(),
    );
  }
}
