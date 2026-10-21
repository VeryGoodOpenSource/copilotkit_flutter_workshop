import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppTheme', () {
    test('light is a Material 3 light theme with the palette', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.accent);
      expect(theme.scaffoldBackgroundColor, AppColors.ground);
      expect(theme.extension<AppPalette>(), isNotNull);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
    });

    test('dark is a Material 3 dark theme with the dark palette', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkGround);
      expect(theme.colorScheme.primary, AppColors.darkAccent);
    });
  });

  group('AppPalette', () {
    test('lerp blends two palettes and ignores foreign extensions', () {
      const a = AppPalette.light();
      const b = AppPalette.dark();
      expect(a.lerp(b, 0).ground, a.ground);
      expect(a.lerp(b, 1).ground, b.ground);
      expect(a.lerp(null, 0.5), same(a));
    });

    test('copyWith overrides selected roles', () {
      const a = AppPalette.light();
      final b = a.copyWith(
        ground: AppColors.navy,
        cardGround: AppColors.navy,
        surface: AppColors.navy,
        navy: AppColors.ground,
        accent: AppColors.negative,
        ink: AppColors.negative,
      );
      expect(b.ground, AppColors.navy);
      expect(b.accent, AppColors.negative);
      expect(b.copyWith().navy, b.navy);
    });

    testWidgets('context.palette falls back to light without a theme '
        'extension', (tester) async {
      late AppPalette palette;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              palette = context.palette;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(palette.ground, AppColors.ground);
    });

    testWidgets('context.palette reads the dark theme', (tester) async {
      late AppPalette palette;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            palette = context.palette;
            return const SizedBox();
          },
        ),
        dark: true,
      );
      expect(palette.ground, AppColors.darkGround);
    });
  });
}
