import 'package:calaverita_domain/models/skull_style.dart';
import 'package:calaverita_domain/models/tone.dart';
import 'package:equatable/equatable.dart';

/// A finished rhyming "literary skull".
class Calaverita extends Equatable {
  const Calaverita({
    required this.name,
    required this.job,
    required this.tone,
    required this.lines,
    this.skull = const SkullStyle(),
  });

  /// Reads a calaverita from JSON, ignoring unknown or invalid fields.
  factory Calaverita.fromJson(Map<String, Object?> json) {
    final lines = json['lines'];
    final skull = json['skull'];
    return Calaverita(
      name: json['name'] is String ? json['name']! as String : '',
      job: json['job'] is String ? json['job']! as String : '',
      tone: Tone.values.asNameMap()[json['tone']] ?? Tone.playful,
      lines: lines is List<Object?> ? lines.whereType<String>().toList() : [],
      skull: skull is Map<String, Object?>
          ? SkullStyle.fromJson(skull)
          : const SkullStyle(),
    );
  }

  final String name;
  final String job;
  final Tone tone;

  /// The portrait that goes with the verse.
  final SkullStyle skull;

  /// The verse, one entry per line.
  final List<String> lines;

  Map<String, Object?> toJson() => {
    'name': name,
    'job': job,
    'tone': tone.name,
    'lines': lines,
    'skull': skull.toJson(),
  };

  @override
  List<Object?> get props => [name, job, tone, lines, skull];
}
