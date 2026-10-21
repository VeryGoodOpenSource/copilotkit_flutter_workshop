import 'package:calaverita_data/templates/calaverita_templates.dart';
import 'package:calaverita_domain/calaverita_domain.dart';

/// Writes calaveritas from ready-made verses, with no network and no agent.
///
/// The same draft always gets the same verse, so results are repeatable.
class TemplateCalaveritasRepository implements ICalaveritasRepository {
  const TemplateCalaveritasRepository({
    CalaveritaTemplates templates = const CalaveritaTemplates(),
    Duration delay = const Duration(milliseconds: 600),
  }) : _templates = templates,
       _delay = delay;

  final CalaveritaTemplates _templates;

  /// How long writing takes, so the loading state is visible.
  final Duration _delay;

  @override
  Future<Calaverita> generate(CalaveritaDraft draft) async {
    if (!draft.isComplete) {
      throw ArgumentError.value(draft, 'draft', 'needs a name and a job');
    }
    await Future<void>.delayed(_delay);
    final name = draft.name.trim();
    final job = draft.job.trim().toLowerCase();
    final verses = _templates.of(draft.tone);
    final seed = '$name$job'.codeUnits.fold(0, (sum, unit) => sum + unit);
    final verse = verses[seed % verses.length];
    return Calaverita(
      name: name,
      job: job,
      tone: draft.tone,
      skull: draft.skull,
      lines: [
        for (final line in verse)
          line.replaceAll('{name}', name).replaceAll('{job}', job),
      ],
    );
  }
}
