import 'package:app_ui/app_ui.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The conversation: the messages and tool calls, an empty state with
/// suggestions, and a composer.
class ChatPanel extends StatelessWidget {
  const ChatPanel({required this.suggestions, super.key});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      navy: true,
      title: 'Copilot',
      icon: AppIcons.sparkle,
      trailing: const _StopButton(),
      child: Column(
        children: [
          Expanded(child: _Feed(suggestions: suggestions)),
          const _Composer(),
        ],
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton();

  @override
  Widget build(BuildContext context) {
    return AgentStateBuilder<bool>(
      selector: (state) => state.isRunning,
      builder: (context, busy) => busy
          ? AppButton.ghost(
              label: 'Stop',
              size: AppButtonSize.compact,
              onNavy: true,
              onPressed: () => context.read<CopilotChatBloc>().add(
                const ChatStopRequested(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({required this.suggestions});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<CopilotChatBloc, CopilotChatState>(
      builder: (context, state) {
        final rows = state.rows.reversed.toList();
        final last = rows.firstOrNull;
        final working =
            state.isRunning &&
            !(last is ChatMessageRow && last.message is AssistantMessage);
        return Column(
          children: [
            Expanded(
              child: rows.isEmpty && !working
                  ? _Empty(suggestions: suggestions)
                  : ListView.separated(
                      // Newest first and anchored to the bottom, like a chat.
                      reverse: true,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      itemCount: rows.length + (working ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        if (working && index == 0) {
                          return const AppTypingBubble(onNavy: true);
                        }
                        return switch (rows[working ? index - 1 : index]) {
                          ChatMessageRow(:final message) => AppChatBubble(
                            key: ValueKey(message.id),
                            text: switch (message) {
                              UserMessage(:final content) => content,
                              AssistantMessage(:final content) => content ?? '',
                              _ => '',
                            },
                            role: message is UserMessage
                                ? AppChatRole.manager
                                : AppChatRole.customer,
                            onNavy: true,
                          ),
                          ChatToolCallRow(:final call) => ToolCallWidget(
                            call: call,
                          ),
                        };
                      },
                    ),
            ),
            if (state.error != null)
              Padding(
                key: const Key('chat_error'),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'The copilot could not answer. Is the runtime running?',
                  style: AppTypography.small.copyWith(color: p.negative),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.suggestions});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x3l,
          children: [
            Text(
              'Tell me about your friend or coworker. I fill in the details '
              'and dress the skull, and you can edit them by hand too.',
              textAlign: TextAlign.center,
              style: AppTypography.small.copyWith(
                color: context.palette.onNavyMuted,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final text in suggestions)
                  AppSuggestionChip(
                    label: text,
                    onTap: () => context.read<CopilotChatBloc>().add(
                      ChatMessageSent(text),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return AgentStateBuilder<bool>(
      selector: (state) => state.isRunning,
      builder: (context, running) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppComposer(
          onNavy: true,
          compact: true,
          enabled: !running,
          hint: 'Tell me about your friend…',
          onSend: (text) =>
              context.read<CopilotChatBloc>().add(ChatMessageSent(text)),
        ),
      ),
    );
  }
}
