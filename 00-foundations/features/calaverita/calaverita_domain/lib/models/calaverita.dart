import 'package:calaverita_domain/models/tone.dart';
import 'package:equatable/equatable.dart';

/// A finished rhyming "literary skull".
class Calaverita extends Equatable {
  const Calaverita({
    required this.name,
    required this.job,
    required this.tone,
    required this.lines,
  });

  final String name;
  final String job;
  final Tone tone;

  /// The verse, one entry per line.
  final List<String> lines;

  @override
  List<Object?> get props => [name, job, tone, lines];
}
