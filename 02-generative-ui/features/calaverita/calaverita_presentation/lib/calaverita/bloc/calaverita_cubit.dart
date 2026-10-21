import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Writes the calaverita for the form.
///
/// The form is the agent's shared state, so the caller hands the current
/// draft in.
class CalaveritaCubit extends Cubit<CalaveritaState> {
  CalaveritaCubit({required ICalaveritasRepository calaveritasRepository})
    : _calaveritasRepository = calaveritasRepository,
      super(const CalaveritaState());

  final ICalaveritasRepository _calaveritasRepository;

  /// Writes a calaverita for [draft], if it is complete.
  Future<void> generate(CalaveritaDraft draft) async {
    if (!draft.isComplete || state.status == GenerationStatus.generating) {
      return;
    }
    emit(state.copyWith(status: GenerationStatus.generating));
    try {
      final calaverita = await _calaveritasRepository.generate(draft);
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
