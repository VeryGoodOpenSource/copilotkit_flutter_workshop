import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppStatTile', () {
    testWidgets('shows label, value and suffix', (tester) async {
      await tester.pumpApp(
        const AppStatTile(label: 'Orders', value: '12', suffix: '/ 30'),
      );
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('/ 30'), findsOneWidget);
      expect(find.byType(AppProgressBar), findsNothing);
    });

    testWidgets('renders every tone on navy and on light', (tester) async {
      for (final onNavy in [true, false]) {
        await tester.pumpApp(
          Column(
            children: [
              for (final tone in AppTone.values)
                AppStatTile(
                  label: tone.name,
                  value: '1',
                  tone: tone,
                  onNavy: onNavy,
                  mono: false,
                ),
            ],
          ),
        );
        expect(find.byType(AppStatTile), findsNWidgets(AppTone.values.length));
      }
    });

    testWidgets('draws progress with target', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 200,
          child: AppStatTile(
            label: 'Score',
            value: '4.5',
            progress: 0.5,
            target: 0.8,
          ),
        ),
      );
      expect(find.byType(AppProgressBar), findsOneWidget);
    });
  });

  group('AppProgressBar', () {
    testWidgets('fills proportionally and clamps', (tester) async {
      await tester.pumpApp(
        const SizedBox(width: 200, child: AppProgressBar(value: 2, target: -1)),
      );
      expect(find.byKey(const Key('appProgressBar_target')), findsOneWidget);
    });

    testWidgets('supports low and navy styles without target', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 200,
          child: Column(
            children: [
              AppProgressBar(value: 0.2, low: true),
              AppProgressBar(value: 0.2, onNavy: true, target: 0.5),
            ],
          ),
        ),
      );
      expect(find.byKey(const Key('appProgressBar_target')), findsOneWidget);
    });
  });

  testWidgets('AppGoalChip renders bold and regular parts', (tester) async {
    await tester.pumpApp(const AppGoalChip(strong: '30', label: 'orders'));
    expect(find.textContaining('orders', findRichText: true), findsOneWidget);
  });

  group('AppKeyValueRow', () {
    testWidgets('renders inset and plain rows with tones', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppKeyValueRow(label: 'Revenue', value: r'$40', mono: true),
            AppKeyValueRow(
              label: 'Late',
              value: '3',
              valueTone: AppTone.negative,
              inset: false,
            ),
          ],
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
