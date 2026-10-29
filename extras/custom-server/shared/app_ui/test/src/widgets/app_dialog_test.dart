import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppDialogScaffold', () {
    testWidgets('renders hero and children', (tester) async {
      await tester.pumpApp(
        const AppDialogScaffold(
          hero: Text('hero'),
          children: [Text('one'), Text('two')],
        ),
      );
      expect(find.text('hero'), findsOneWidget);
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('renders without hero', (tester) async {
      await tester.pumpApp(const AppDialogScaffold(children: [Text('one')]));
      expect(find.text('one'), findsOneWidget);
    });
  });

  group('AppWelcomeDialog', () {
    testWidgets('renders all sections and fires the action', (tester) async {
      var taps = 0;
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        AppWelcomeDialog(
          hero: const AppUnicorn(size: 80),
          brand: 'Very Good Coffee',
          title: 'Welcome',
          paragraphs: const ['Run the shop.'],
          steps: const [AppDialogStep(strong: '1.', text: 'Watch')],
          goals: const [AppGoalChip(strong: '30', label: 'orders')],
          footnote: 'Good luck',
          actionLabel: 'Start',
          onAction: () => taps++,
        ),
      );
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Very Good Coffee'), findsOneWidget);
      expect(find.text('Run the shop.'), findsOneWidget);
      expect(find.text('Good luck'), findsOneWidget);
      await tester.tap(find.text('Start'));
      expect(taps, 1);
    });

    testWidgets('renders with only required parts', (tester) async {
      await tester.pumpApp(
        AppWelcomeDialog(
          hero: const SizedBox(),
          title: 'Hi',
          actionLabel: 'Go',
          onAction: () {},
        ),
      );
      expect(find.text('Hi'), findsOneWidget);
    });
  });

  group('AppDialogStep', () {
    testWidgets('renders with and without a bold lead-in', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppDialogStep(strong: 'Bold', text: 'rest'),
            AppDialogStep(text: 'plain'),
          ],
        ),
      );
      expect(find.textContaining('rest', findRichText: true), findsOneWidget);
      expect(find.textContaining('plain', findRichText: true), findsOneWidget);
    });
  });

  group('AppResultDialog', () {
    testWidgets('won state shows a trophy and fires the action', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppResultDialog(
          title: 'You won',
          message: 'Nice',
          checks: const [AppKeyValueRow(label: 'Orders', value: '30')],
          extra: const Text('week'),
          actionLabel: 'Again',
          onAction: () => taps++,
        ),
      );
      expect(find.text('You won'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('week'), findsOneWidget);
      await tester.tap(find.text('Again'));
      expect(taps, 1);
    });

    testWidgets('lost state renders without optional parts', (tester) async {
      await tester.pumpApp(
        AppResultDialog(
          title: 'Closed',
          won: false,
          actionLabel: 'Retry',
          onAction: () {},
        ),
      );
      expect(find.text('Closed'), findsOneWidget);
    });
  });

  group('showAppDialog', () {
    for (final branded in [true, false]) {
      testWidgets('opens a modal (branded: $branded) and dismisses it', (
        tester,
      ) async {
        await tester.pumpApp(
          Builder(
            builder: (context) => AppButton(
              label: 'Open',
              onPressed: () => showAppDialog<void>(
                context: context,
                branded: branded,
                dismissible: true,
                builder: (_) => const Text('modal'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('modal'), findsOneWidget);
        await tester.tapAt(const Offset(2, 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('modal'), findsNothing);
      });
    }
  });
}
