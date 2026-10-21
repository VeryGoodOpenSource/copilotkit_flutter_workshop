import 'package:assistant_presentation/chat/views/chat_view.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/widgets.dart';

/// The chat with the agent [agentId].
///
/// It must sit below a `CopilotKit`, which connects it to the runtime.
class ChatModule extends StatelessWidget {
  const ChatModule({required this.agentId, super.key});

  /// Id of the agent on the runtime, e.g. `default`.
  final String agentId;

  @override
  Widget build(BuildContext context) {
    return CopilotChatProvider(agentId: agentId, child: const ChatView());
  }
}
