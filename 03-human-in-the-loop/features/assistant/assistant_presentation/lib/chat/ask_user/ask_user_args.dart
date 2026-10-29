import 'package:equatable/equatable.dart';

/// One answer the agent offers in an `askUser` question.
class AskUserOption extends Equatable {
  const AskUserOption({required this.id, required this.label, this.hint});

  /// Reads an option from JSON, or returns `null` without an id or a label.
  static AskUserOption? tryFromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final id = json['id'];
    final label = json['label'];
    final hint = json['hint'];
    if (id is! String || id.isEmpty || label is! String || label.isEmpty) {
      return null;
    }
    return AskUserOption(
      id: id,
      label: label,
      hint: hint is String && hint.isNotEmpty ? hint : null,
    );
  }

  /// What goes back to the agent when this option is picked.
  final String id;

  /// What the person reads on the button.
  final String label;

  /// A short line under the label, if the agent gave one.
  final String? hint;

  @override
  List<Object?> get props => [id, label, hint];
}

/// The arguments of the `askUser` tool: a question and its options.
class AskUserArgs extends Equatable {
  const AskUserArgs({this.question = '', this.options = const []});

  factory AskUserArgs.fromJson(Map<String, Object?> json) {
    final question = json['question'];
    final options = json['options'];
    return AskUserArgs(
      question: question is String ? question : '',
      options: options is List<Object?>
          ? [for (final option in options) ?AskUserOption.tryFromJson(option)]
          : const [],
    );
  }

  final String question;
  final List<AskUserOption> options;

  @override
  List<Object?> get props => [question, options];
}
