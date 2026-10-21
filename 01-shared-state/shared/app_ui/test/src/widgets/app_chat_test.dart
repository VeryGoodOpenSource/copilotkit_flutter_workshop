import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppChatBubble', () {
    testWidgets('renders text, sender and timestamp', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 400,
          child: AppChatBubble(
            text: 'Where is my latte?',
            role: AppChatRole.customer,
            sender: 'Ana',
            timestamp: '09:12',
          ),
        ),
      );
      expect(find.text('Where is my latte?'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('09:12'), findsOneWidget);
    });

    testWidgets('renders every role on light and navy', (tester) async {
      for (final onNavy in [false, true]) {
        for (final accent in [false, true]) {
          await tester.pumpApp(
            SizedBox(
              width: 400,
              child: Column(
                children: [
                  for (final role in AppChatRole.values)
                    AppChatBubble(
                      text: role.name,
                      role: role,
                      onNavy: onNavy,
                      accent: accent,
                    ),
                ],
              ),
            ),
          );
          expect(find.byType(AppChatBubble), findsNWidgets(3));
        }
      }
    });
  });

  group('AppTypingBubble', () {
    testWidgets('animates three dots', (tester) async {
      for (final onNavy in [false, true]) {
        await tester.pumpApp(AppTypingBubble(onNavy: onNavy), settle: false);
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.byType(AppTypingBubble), findsOneWidget);
      }
    });
  });

  group('AppComposer', () {
    testWidgets('sends trimmed text on tap and clears the field', (
      tester,
    ) async {
      final sent = <String>[];
      await tester.pumpApp(
        SizedBox(width: 400, child: AppComposer(onSend: sent.add)),
      );
      await tester.enterText(find.byType(TextField), '  hello  ');
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump();
      expect(sent, ['hello']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('sends on keyboard submit and ignores empty text', (
      tester,
    ) async {
      final sent = <String>[];
      await tester.pumpApp(
        SizedBox(
          width: 400,
          child: AppComposer(onSend: sent.add, onNavy: true, compact: true),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Send'));
      expect(sent, isEmpty);
      await tester.enterText(find.byType(TextField), 'go');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(sent, ['go']);
    });

    testWidgets('does nothing when disabled', (tester) async {
      final sent = <String>[];
      await tester.pumpApp(
        SizedBox(
          width: 400,
          child: AppComposer(onSend: sent.add, enabled: false),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Send'));
      expect(sent, isEmpty);
    });
  });

  group('AppSuggestionChip', () {
    testWidgets('fires onTap on navy and light', (tester) async {
      var taps = 0;
      for (final onNavy in [true, false]) {
        await tester.pumpApp(
          AppSuggestionChip(
            label: 'Who is slow?',
            onTap: () => taps++,
            onNavy: onNavy,
          ),
        );
        await tester.tap(find.text('Who is slow?'));
      }
      expect(taps, 2);
    });
  });
}
