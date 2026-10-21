import 'package:app_ui/app_ui.dart';
import 'package:assistant_presentation/chat/views/activity_line.dart';
import 'package:assistant_presentation/chat/views/chat_panel.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';

/// The chat with the agent [agentId].
///
/// It must sit below a `CopilotKit`, which connects it to the runtime.
class ChatModule extends StatelessWidget {
  const ChatModule({
    required this.agentId,
    this.suggestions = const [],
    super.key,
  });

  /// Id of the agent on the runtime, e.g. `default`.
  final String agentId;

  /// Messages offered as chips while the chat is empty.
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    // The scope shares its agent with any other scope of the same id, so
    // this is the agent the rest of the screen reads and edits.
    return CopilotAgentScope(
      agentId: agentId,
      child: CopilotChatProvider(
        agentId: agentId,
        // The agent's own tool calls (changing the shared state) show as one
        // quiet line instead of raw arguments.
        child: ToolRenderer(
          name: ToolRenderer.nameFallback,
          builder: (context, call) => ActivityLine(call: call),
          child: ChatPanel(suggestions: suggestions),
        ),
      ),
    );
  }
}
