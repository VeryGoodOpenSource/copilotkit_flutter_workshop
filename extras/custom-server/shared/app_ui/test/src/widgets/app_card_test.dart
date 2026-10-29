import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child with and without shadow/clip', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppCard(child: Text('a')),
            AppCard(shadow: false, clip: false, child: Text('b')),
          ],
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('AppSectionHeader', () {
    testWidgets('shows title, icon and trailing', (tester) async {
      await tester.pumpApp(
        const AppSectionHeader(
          title: 'Requested',
          icon: AppIcons.coffee,
          trailing: AppCountBadge(count: 2),
        ),
      );
      expect(find.text('Requested'), findsOneWidget);
      expect(find.byType(AppIcon), findsOneWidget);
      expect(find.byType(AppCountBadge), findsOneWidget);
    });

    testWidgets('works on navy without icon', (tester) async {
      await tester.pumpApp(
        const AppSectionHeader(title: 'Copilot', onNavy: true),
      );
      expect(find.byType(AppIcon), findsNothing);
    });
  });

  group('AppPanel', () {
    testWidgets('renders a titled body in both styles', (tester) async {
      for (final navy in [false, true]) {
        await tester.pumpApp(
          SizedBox(
            height: 200,
            width: 300,
            child: AppPanel(
              title: 'Panel',
              icon: AppIcons.usersThree,
              trailing: const AppChip(label: 'x'),
              navy: navy,
              child: const Text('body'),
            ),
          ),
        );
        expect(find.text('Panel'), findsOneWidget);
        expect(find.text('body'), findsOneWidget);
      }
    });
  });
}
