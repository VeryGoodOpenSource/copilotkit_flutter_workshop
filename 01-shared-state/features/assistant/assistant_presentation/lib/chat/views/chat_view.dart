import 'package:assistant_presentation/chat/views/composer.dart';
import 'package:assistant_presentation/chat/views/message_list.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The messages above a composer, with an error banner when the last run
/// failed.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = context.select<CopilotChatBloc, bool>(
      (bloc) => bloc.state.error != null,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Assistant', style: theme.textTheme.titleMedium),
          ),
        ),
        const Expanded(child: MessageList()),
        if (hasError)
          Padding(
            key: const Key('chat_error'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Something went wrong. Is the runtime running?',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        const Composer(),
      ],
    );
  }
}
