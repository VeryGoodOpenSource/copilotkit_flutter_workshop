import 'package:calaverita_domain/models/calaverita.dart';
import 'package:calaverita_domain/models/calaverita_draft.dart';

/// Writes calaveritas.
abstract interface class ICalaveritasRepository {
  /// Writes a calaverita for [draft].
  ///
  /// Throws an [ArgumentError] when [CalaveritaDraft.isComplete] is false.
  Future<Calaverita> generate(CalaveritaDraft draft);
}
