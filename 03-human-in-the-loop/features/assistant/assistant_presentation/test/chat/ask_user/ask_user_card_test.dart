import 'package:app_ui/app_ui.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_args.dart';
import 'package:assistant_presentation/chat/ask_user/ask_user_card.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const args = AskUserArgs(
    question: 'How should I roast Mario?',
    options: [
      AskUserOption(id: 'playful', label: 'Playful'),
      AskUserOption(id: 'sarcastic', label: 'Sarcastic', hint: 'A bit sharper'),
    ],
  );

  ToolCallView call(ToolCallStatus status, {String? result}) => ToolCallView(
    id: 'call-1',
    name: 'askUser',
    status: status,
    result: result,
  );

  Future<void> pump(
    WidgetTester tester, {
    required ToolCallView call,
    AskUserArgs? args,
    ToolCallResponder? respond,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AskUserCard(call: call, args: args, respond: respond),
        ),
      ),
    );
  }

  group(AskUserCard, () {
    testWidgets('shows the question and answers with the id of the option', (
      tester,
    ) async {
      Object? answer;
      await pump(
        tester,
        call: call(ToolCallStatus.executing),
        args: args,
        respond: (result) => answer = result,
      );

      expect(find.text('How should I roast Mario?'), findsOneWidget);
      expect(find.text('A bit sharper'), findsOneWidget);

      await tester.tap(find.text('Sarcastic'));

      expect(answer, 'sarcastic');
    });

    testWidgets('cannot be answered while it does not wait for the person', (
      tester,
    ) async {
      await pump(tester, call: call(ToolCallStatus.inProgress), args: args);

      // Nothing to call: tapping an option does nothing and does not throw.
      await tester.tap(find.text('Playful'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps a placeholder while the question is still arriving', (
      tester,
    ) async {
      await pump(tester, call: call(ToolCallStatus.inProgress));

      expect(find.text('How should I roast Mario?'), findsNothing);
      expect(find.byType(AppDecisionCard), findsOneWidget);
    });

    testWidgets('shows the answer once the call is complete', (tester) async {
      await pump(
        tester,
        call: call(ToolCallStatus.complete, result: 'sarcastic'),
        args: args,
      );

      final tiles = tester.widgetList<AppOptionTile>(
        find.byType(AppOptionTile),
      );
      expect(
        {for (final tile in tiles) tile.label: tile.selected},
        {'Playful': false, 'Sarcastic': true},
      );
      expect(
        tester.widget<AppDecisionCard>(find.byType(AppDecisionCard)).complete,
        isTrue,
      );
    });
  });
}
