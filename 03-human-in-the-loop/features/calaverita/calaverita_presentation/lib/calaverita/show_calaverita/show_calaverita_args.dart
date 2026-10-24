import 'package:equatable/equatable.dart';

/// The arguments of the `showCalaverita` tool: the verse the agent wrote.
class ShowCalaveritaArgs extends Equatable {
  const ShowCalaveritaArgs({this.lines = const []});

  factory ShowCalaveritaArgs.fromJson(Map<String, Object?> json) {
    final lines = json['lines'];
    return ShowCalaveritaArgs(
      lines: lines is List<Object?> ? lines.whereType<String>().toList() : [],
    );
  }

  /// The four lines of the verse.
  final List<String> lines;

  @override
  List<Object?> get props => [lines];
}
