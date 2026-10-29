import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpApp(AppButton(label: 'Start', onPressed: () => taps++));
      expect(find.text('Start'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(taps, 1);
    });

    testWidgets('is dimmed and inert when disabled', (tester) async {
      await tester.pumpApp(const AppButton.ghost(label: 'No', onPressed: null));
      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('shows icon and supports every size / variant', (tester) async {
      for (final size in AppButtonSize.values) {
        for (final onNavy in [false, true]) {
          await tester.pumpApp(
            Column(
              children: [
                AppButton.primary(
                  label: 'P',
                  onPressed: () {},
                  icon: AppIcons.play,
                  size: size,
                  onNavy: onNavy,
                  expanded: true,
                ),
                AppButton.ghost(
                  label: 'G',
                  onPressed: () {},
                  size: size,
                  onNavy: onNavy,
                ),
              ],
            ),
          );
          expect(find.byType(AppIcon), findsOneWidget);
        }
      }
    });

    testWidgets('press scales down and releases', (tester) async {
      await tester.pumpApp(AppButton(label: 'Go', onPressed: () {}));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AppButton)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        lessThan(1),
      );
      await gesture.cancel();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    });
  });

  group('AppIconButton', () {
    testWidgets('fires onPressed in all variants', (tester) async {
      var taps = 0;
      for (final primary in [false, true]) {
        for (final onNavy in [false, true]) {
          await tester.pumpApp(
            AppIconButton(
              icon: AppIcons.pause,
              semanticLabel: 'Pause',
              onPressed: () => taps++,
              primary: primary,
              onNavy: onNavy,
            ),
          );
          await tester.tap(find.byType(AppIconButton));
        }
      }
      expect(taps, 4);
    });

    testWidgets('is dimmed when disabled', (tester) async {
      await tester.pumpApp(
        const AppIconButton(
          icon: AppIcons.pause,
          semanticLabel: 'Pause',
          onPressed: null,
        ),
      );
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        lessThan(1),
      );
    });
  });

  group('AppSegmented', () {
    testWidgets('reports taps and highlights selection', (tester) async {
      String? picked;
      await tester.pumpApp(
        AppSegmented<String>(
          segments: const {'a': 'Slow', 'b': 'Fast'},
          value: 'a',
          onChanged: (v) => picked = v,
        ),
      );
      await tester.tap(find.text('Fast'));
      expect(picked, 'b');
    });

    testWidgets('supports navy, compact and disabled', (tester) async {
      await tester.pumpApp(
        const AppSegmented<int>(
          segments: {1: 'One', 2: 'Two'},
          value: 2,
          onChanged: null,
          onNavy: true,
          compact: true,
        ),
      );
      expect(find.text('One'), findsOneWidget);
      await tester.tap(find.text('One'));
    });
  });
}
