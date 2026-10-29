import 'package:assistant_presentation/assistant_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offers the suggestions while the chat is empty', (tester) async {
    await tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in this test runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: const MaterialApp(
          home: Scaffold(
            body: ChatModule(agentId: 'default', suggestions: ['Hola']),
          ),
        ),
      ),
    );

    expect(find.text('Copilot'), findsOneWidget);
    expect(find.text('Hola'), findsOneWidget);
  });

  testWidgets('sends a suggestion as a message', (tester) async {
    await tester.pumpWidget(
      CopilotKit(
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: const MaterialApp(
          home: Scaffold(
            body: ChatModule(agentId: 'default', suggestions: ['Hola']),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hola'));
    await tester.pump();

    expect(find.text('Hola'), findsOneWidget);
    // The suggestion became a user bubble, so the empty state is gone.
    expect(
      find.textContaining('Tell me about your friend or coworker'),
      findsNothing,
    );
  });
}
