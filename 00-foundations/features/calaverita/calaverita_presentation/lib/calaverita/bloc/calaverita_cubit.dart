import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the form and writes the calaverita.
///
/// All the state is local to the app: nothing here talks to an agent.
class CalaveritaCubit extends Cubit<CalaveritaState> {
  CalaveritaCubit({required ICalaveritasRepository calaveritasRepository})
    : _calaveritasRepository = calaveritasRepository,
      super(const CalaveritaState());

  final ICalaveritasRepository _calaveritasRepository;

  void nameChanged(String name) => _editDraft(state.draft.copyWith(name: name));

  void jobChanged(String job) => _editDraft(state.draft.copyWith(job: job));

  void toneChanged(Tone tone) => _editDraft(state.draft.copyWith(tone: tone));

  /// Makes the skull wear [variant] of [part], or take it off with
  /// [SkullStyle.none].
  void skullPartChanged(SkullPart part, String variant) => _editDraft(
    state.draft.copyWith(skull: state.draft.skull.wearing(part, variant)),
  );

  /// Paints the skull in [color], as `#rrggbb`.
  void skullColorChanged(String color) => _editDraft(
    state.draft.copyWith(skull: state.draft.skull.withColor(color)),
  );

  void _editDraft(CalaveritaDraft draft) => emit(state.copyWith(draft: draft));

  /// Writes a calaverita for the current form, if it is complete.
  Future<void> generate() async {
    if (!state.canGenerate) return;
    emit(state.copyWith(status: GenerationStatus.generating));
    try {
      final calaverita = await _calaveritasRepository.generate(state.draft);
      emit(
        state.copyWith(
          status: GenerationStatus.success,
          calaverita: calaverita,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: GenerationStatus.failure));
    }
  }
}
