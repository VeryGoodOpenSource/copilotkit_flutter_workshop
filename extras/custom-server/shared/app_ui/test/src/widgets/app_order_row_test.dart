import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppOrderRow', () {
    testWidgets('shows texts and fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SizedBox(
          width: 300,
          child: AppOrderRow(
            title: 'Ana',
            subtitle: '2x Latte',
            trailing: '0:42',
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('2x Latte'), findsOneWidget);
      expect(find.text('0:42'), findsOneWidget);
      expect(find.byKey(const Key('appOrderRow_stripe')), findsNothing);
      await tester.tap(find.byType(AppOrderRow));
      expect(taps, 1);
    });

    testWidgets('draws a stripe for warn, urgent and done', (tester) async {
      for (final urgency in [
        AppUrgency.warn,
        AppUrgency.urgent,
        AppUrgency.done,
      ]) {
        await tester.pumpApp(
          SizedBox(
            width: 300,
            child: AppOrderRow(
              title: 'Ana',
              subtitle: 'Latte',
              urgency: urgency,
              selected: true,
              unread: true,
            ),
          ),
          settle: false,
        );
        await tester.pump(const Duration(milliseconds: 800));
        expect(find.byKey(const Key('appOrderRow_stripe')), findsOneWidget);
      }
    });

    testWidgets('done shows a check and hides trailing text', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 300,
          child: AppOrderRow(
            title: 'Ana',
            subtitle: 'Latte',
            trailing: '0:10',
            urgency: AppUrgency.done,
          ),
        ),
      );
      expect(find.text('0:10'), findsNothing);
      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('stops pulsing when no longer urgent', (tester) async {
      Widget row(AppUrgency u) => SizedBox(
        width: 300,
        child: AppOrderRow(title: 'A', subtitle: 'B', urgency: u),
      );
      await tester.pumpApp(row(AppUrgency.urgent), settle: false);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpApp(row(AppUrgency.urgent), settle: false);
      await tester.pumpApp(row(AppUrgency.normal));
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('AppAvatar / AppPersonRow', () {
    testWidgets('avatar shows the uppercase initial or ?', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppAvatar(name: 'bea'),
            AppAvatar(name: '', alert: true),
          ],
        ),
      );
      expect(find.text('B'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('person row shows caption, meter and trailing', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 300,
          child: Column(
            children: [
              AppPersonRow(
                name: 'Bea',
                caption: '3 min',
                meter: 0.6,
                meterTarget: 0.7,
                trailing: '4',
              ),
              AppPersonRow(
                name: 'Cy',
                caption: 'slow',
                meter: 0.1,
                alert: true,
              ),
            ],
          ),
        ),
      );
      expect(find.text('3 min'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.byType(AppProgressBar), findsNWidgets(2));
    });
  });
}
