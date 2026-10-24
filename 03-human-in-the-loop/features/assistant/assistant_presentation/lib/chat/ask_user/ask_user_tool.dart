import 'package:ack/ack.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_args.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_card.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/widgets.dart';

/// Gives the agent an `askUser` tool and draws its calls as an [AskUserCard]
/// in [child], e.g. the chat.
///
/// This is human in the loop: the agent asks, its run waits, and the answer
/// the person taps goes back to the agent as the tool result. The answer is
/// the id of the option.
class AskUserTool extends StatefulWidget {
  const AskUserTool({required this.child, super.key});

  final Widget child;

  @override
  State<AskUserTool> createState() => _AskUserToolState();
}

class _AskUserToolState extends State<AskUserTool> {
  /// Kept in a field: the SDK compares tools to know whether to register
  /// again.
  late final _tool = HumanInTheLoopTool<AskUserArgs>(
    name: 'askUser',
    description:
        'Ask the user to pick one of a few options, then wait for the answer. '
        'It comes back as the id of the option they picked. Use it for a '
        'choice that is theirs to make, one question at a time.',
    // Keep in sync with AskUserArgs.
    parameters: Ack.object({
      'question': Ack.string().describe('The question, one short sentence'),
      'options': Ack.list(
        Ack.object({
          'id': Ack.string().describe('A short id, e.g. playful'),
          'label': Ack.string().describe('What the button says'),
          'hint': Ack.string().optional().describe('An optional short line'),
        }),
      ).describe('Two to four options'),
    }),
    decode: AskUserArgs.fromJson,
  );

  @override
  Widget build(BuildContext context) {
    return CopilotHumanInTheLoop<AskUserArgs>(
      tool: _tool,
      builder: (context, call, args, respond) =>
          AskUserCard(call: call, args: args, respond: respond),
      child: widget.child,
    );
  }
}
