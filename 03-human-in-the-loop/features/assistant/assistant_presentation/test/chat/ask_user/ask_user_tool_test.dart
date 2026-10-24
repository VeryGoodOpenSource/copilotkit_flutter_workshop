import 'package:app_ui/app_ui.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_card.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_tool.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Renders [call] the way the chat does: through a `ToolCallWidget` below
  /// the tool.
  Future<void> pumpCall(WidgetTester tester, ToolCallView call) {
    return tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in these tests runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AskUserTool(child: ToolCallWidget(call: call)),
          ),
        ),
      ),
    );
  }

  group(AskUserTool, () {
    testWidgets('draws a call to askUser as a card with its options', (
      tester,
    ) async {
      await pumpCall(
        tester,
        const ToolCallView(
          id: 'call-1',
          name: 'askUser',
          status: ToolCallStatus.executing,
          awaitingResponse: true,
          args: {
            'question': 'How should I roast Mario?',
            'options': [
              {'id': 'playful', 'label': 'Playful'},
              {'id': 'dramatic', 'label': 'Dramatic'},
            ],
          },
        ),
      );

      expect(find.byType(AskUserCard), findsOneWidget);
      expect(find.text('How should I roast Mario?'), findsOneWidget);
      expect(find.text('Dramatic'), findsOneWidget);
    });
  });
}
