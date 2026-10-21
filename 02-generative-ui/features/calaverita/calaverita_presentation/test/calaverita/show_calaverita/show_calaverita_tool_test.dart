import 'dart:convert';

import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/test_skull_art.dart';

void main() {
  const calaverita = Calaverita(
    name: 'Ana',
    job: 'pilot',
    tone: Tone.sarcastic,
    lines: ['one', 'two', 'three', 'four'],
  );

  /// Renders [call] the way the chat does: through a `ToolCallWidget` below
  /// the tool.
  Future<void> pumpCall(WidgetTester tester, ToolCallView call) {
    return tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in these tests runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: MaterialApp(
          home: Provider<SkullArt>.value(
            value: TestSkullArt.build(),
            child: CopilotAgentScope(
              agentId: 'default',
              child: Scaffold(
                body: ShowCalaveritaTool(child: ToolCallWidget(call: call)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ToolCallView callWith(ToolCallStatus status, {String? result}) =>
      ToolCallView(
        id: 'call-1',
        name: 'showCalaverita',
        status: status,
        result: result,
      );

  group(ShowCalaveritaTool, () {
    testWidgets('shows a placeholder while the agent writes', (tester) async {
      await pumpCall(tester, callWith(ToolCallStatus.inProgress));

      expect(find.text('Writing the calaverita…'), findsOneWidget);
      expect(find.byType(CalaveritaCard), findsNothing);
    });

    testWidgets('shows the card once the call is complete', (tester) async {
      await pumpCall(
        tester,
        callWith(
          ToolCallStatus.complete,
          result: jsonEncode(calaverita.toJson()),
        ),
      );

      expect(find.byType(CalaveritaCard), findsOneWidget);
      expect(find.text('Calaverita for Ana'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
    });

    testWidgets('shows the message when the result is not a calaverita', (
      tester,
    ) async {
      await pumpCall(
        tester,
        callWith(
          ToolCallStatus.complete,
          result: 'The form still needs a name and a job.',
        ),
      );

      expect(find.byType(CalaveritaCard), findsNothing);
      expect(find.textContaining('still needs a name'), findsOneWidget);
    });
  });
}
