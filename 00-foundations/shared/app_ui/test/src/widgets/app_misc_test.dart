import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppToast', () {
    testWidgets('fades in the message', (tester) async {
      await tester.pumpApp(const AppToast(message: 'Day 2'), settle: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Day 2'), findsOneWidget);
    });
  });

  group('AppIcon', () {
    testWidgets('resolves every style', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            for (final style in AppIconStyle.values)
              AppIcon(AppIcons.coffee, style: style, semanticLabel: style.name),
          ],
        ),
      );
      expect(find.byType(AppIcon), findsNWidgets(3));
    });

    test('every icon set has three distinct glyphs', () {
      const sets = [
        AppIcons.coffee,
        AppIcons.package,
        AppIcons.moped,
        AppIcons.mapPin,
        AppIcons.checkCircle,
        AppIcons.xCircle,
        AppIcons.warning,
        AppIcons.star,
        AppIcons.receipt,
        AppIcons.currencyDollar,
        AppIcons.usersThree,
        AppIcons.chat,
        AppIcons.play,
        AppIcons.pause,
        AppIcons.signOut,
        AppIcons.restart,
        AppIcons.lightning,
        AppIcons.wrench,
        AppIcons.send,
        AppIcons.trophy,
        AppIcons.sparkle,
        AppIcons.clock,
        AppIcons.arrowRight,
        AppIcons.check,
      ];
      for (final set in sets) {
        expect(set.resolve(AppIconStyle.regular), set.regular);
        expect(set.resolve(AppIconStyle.fill), set.fill);
        expect(set.resolve(AppIconStyle.duotone), set.duotone);
      }
    });
  });

  group('brand', () {
    testWidgets('AppUnicorn picks the asset for the background', (
      tester,
    ) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppUnicorn(size: 40),
            AppUnicorn(size: 40, onNavy: false, semanticLabel: 'VGV'),
          ],
        ),
      );
      expect(find.byType(AppUnicorn), findsNWidgets(2));
    });

    testWidgets('AppVgvLockup renders plain and tinted', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppVgvLockup(height: 40),
            AppVgvLockup(height: 40, color: AppColors.accent),
          ],
        ),
      );
      expect(find.byType(AppVgvLockup), findsNWidgets(2));
    });

    test('asset paths point into the package', () {
      expect(AppAssets.unicorn, endsWith('unicorn.svg'));
      expect(AppAssets.unicornDark, endsWith('unicorn-dark.svg'));
      expect(AppAssets.vgvLockup, endsWith('vgv-lockup.svg'));
    });
  });
}
