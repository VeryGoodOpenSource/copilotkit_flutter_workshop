import 'package:calaverita_domain/models/tone.dart';
import 'package:equatable/equatable.dart';

/// What we know about the person a calaverita is written for.
///
/// This is the shape of the form, and later the shape the agent shares with
/// the app, so it knows how to read and write itself as JSON.
class CalaveritaDraft extends Equatable {
  const CalaveritaDraft({
    this.name = '',
    this.job = '',
    this.tone = Tone.playful,
  });

  /// Reads a draft from JSON, ignoring unknown or invalid fields.
  factory CalaveritaDraft.fromJson(Map<String, Object?> json) {
    final tone = json['tone'];
    return CalaveritaDraft(
      name: json['name'] is String ? json['name']! as String : '',
      job: json['job'] is String ? json['job']! as String : '',
      tone: Tone.values.asNameMap()[tone] ?? Tone.playful,
    );
  }

  final String name;
  final String job;
  final Tone tone;

  /// Whether there is enough to write a calaverita.
  bool get isComplete => name.trim().isNotEmpty && job.trim().isNotEmpty;

  CalaveritaDraft copyWith({String? name, String? job, Tone? tone}) =>
      CalaveritaDraft(
        name: name ?? this.name,
        job: job ?? this.job,
        tone: tone ?? this.tone,
      );

  Map<String, Object?> toJson() => {
    'name': name,
    'job': job,
    'tone': tone.name,
  };

  @override
  List<Object?> get props => [name, job, tone];
}
