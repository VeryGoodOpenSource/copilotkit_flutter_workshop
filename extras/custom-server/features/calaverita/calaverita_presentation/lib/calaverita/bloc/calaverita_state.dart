import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:equatable/equatable.dart';

/// Where writing a calaverita stands.
enum GenerationStatus { idle, generating, success, failure }

/// The calaverita being written, or the last one written.
///
/// The form itself is not here: it lives in the agent's shared state.
class CalaveritaState extends Equatable {
  const CalaveritaState({this.status = GenerationStatus.idle, this.calaverita});

  final GenerationStatus status;

  /// The last calaverita written, if any.
  final Calaverita? calaverita;

  CalaveritaState copyWith({
    GenerationStatus? status,
    Calaverita? calaverita,
  }) => CalaveritaState(
    status: status ?? this.status,
    calaverita: calaverita ?? this.calaverita,
  );

  @override
  List<Object?> get props => [status, calaverita];
}
