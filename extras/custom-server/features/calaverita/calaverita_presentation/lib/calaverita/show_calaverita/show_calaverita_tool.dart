import 'package:ack/ack.dart';
import 'package:calaverita_presentation/calaverita/bloc/calaverita_cubit.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/shared_draft.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_args.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_card.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_handler.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Gives the agent a `showCalaverita` tool and draws its calls as a
/// [ShowCalaveritaCard] in [child], e.g. the chat.
///
/// The agent writes the verse and calls the tool, the tool adds the form and
/// the skull as they are right now, and the card in the chat shows the
/// result. The stage shows it too, so the verse the agent wrote is the one on
/// the main screen. Needs a `CopilotAgentScope` and the calaverita screen's
/// cubit above it.
class ShowCalaveritaTool extends StatefulWidget {
  const ShowCalaveritaTool({required this.child, super.key});

  final Widget child;

  @override
  State<ShowCalaveritaTool> createState() => _ShowCalaveritaToolState();
}

class _ShowCalaveritaToolState extends State<ShowCalaveritaTool> {
  /// Kept in a field: the SDK compares tools to know whether to register
  /// again.
  FrontendTool<ShowCalaveritaArgs>? _tool;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tool != null) return;
    final agent = CopilotAgentScope.of(context);
    final cubit = context.read<CalaveritaCubit>();
    _tool = FrontendTool<ShowCalaveritaArgs>(
      name: 'showCalaverita',
      description:
          'Show a finished calaverita to the user as a card in the chat, with '
          'the skull portrait that is on screen. Call it once the name and '
          'the job are filled in and the user asks for the calaverita.',
      // Keep in sync with ShowCalaveritaArgs.
      parameters: Ack.object({
        'lines': Ack.list(Ack.string())
            .describe('The four rhyming lines of the calaverita, in order'),
      }),
      decode: ShowCalaveritaArgs.fromJson,
      handler: ShowCalaveritaHandler(
        readDraft: () => SharedDraft.draftOf(agent.state),
        onWritten: cubit.calaveritaShown,
      ).handle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CopilotTool<ShowCalaveritaArgs>(
      tool: _tool!,
      builder: (context, call, args) =>
          ShowCalaveritaCard(call: call, args: args),
      child: widget.child,
    );
  }
}
