import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:equatable/equatable.dart';

/// Where writing a calaverita stands.
enum GenerationStatus { idle, generating, success, failure }

/// The form the person is filling in and the calaverita it produced.
class CalaveritaState extends Equatable {
  const CalaveritaState({
    this.draft = const CalaveritaDraft(),
    this.status = GenerationStatus.idle,
    this.calaverita,
  });

  final CalaveritaDraft draft;
  final GenerationStatus status;

  /// The last calaverita written, if any.
  final Calaverita? calaverita;

  bool get canGenerate =>
      draft.isComplete && status != GenerationStatus.generating;

  CalaveritaState copyWith({
    CalaveritaDraft? draft,
    GenerationStatus? status,
    Calaverita? calaverita,
  }) => CalaveritaState(
    draft: draft ?? this.draft,
    status: status ?? this.status,
    calaverita: calaverita ?? this.calaverita,
  );

  @override
  List<Object?> get props => [draft, status, calaverita];
}
