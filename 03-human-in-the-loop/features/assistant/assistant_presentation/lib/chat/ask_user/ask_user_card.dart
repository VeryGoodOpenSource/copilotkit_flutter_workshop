import 'package:app_ui/app_ui.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_args.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// The generative UI of an `askUser` call: the question with its options as
/// tiles.
///
/// The tiles answer the call while it waits for the person (`respond` is set),
/// and the card flattens to show the answer once the call is complete.
class AskUserCard extends StatelessWidget {
  const AskUserCard({
    required this.call,
    required this.respond,
    this.args,
    super.key,
  });

  /// The call to show.
  final ToolCallView call;

  /// Answers the call, or `null` unless it waits for the person.
  final ToolCallResponder? respond;

  /// The arguments of [call], or `null` while they can't be decoded yet.
  final AskUserArgs? args;

  @override
  Widget build(BuildContext context) {
    final answered = call.status == ToolCallStatus.complete;
    final question = args?.question ?? '';
    return AppDecisionCard(
      kindLabel: 'Question',
      kindIcon: AppIcons.chat,
      title: question.isEmpty ? null : question,
      loading: question.isEmpty && !answered,
      complete: answered,
      children: [
        for (final option in args?.options ?? const <AskUserOption>[])
          AppOptionTile(
            label: option.label,
            detail: option.hint,
            selected: answered && call.result == option.id,
            onTap: respond == null ? null : () => respond!(option.id),
          ),
      ],
    );
  }
}
