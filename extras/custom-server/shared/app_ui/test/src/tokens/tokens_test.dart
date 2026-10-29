import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tokens', () {
    test('spacing scale is ascending', () {
      final scale = [
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.x3l,
        AppSpacing.x4l,
        AppSpacing.x5l,
        AppSpacing.x6l,
        AppSpacing.x7l,
      ];
      expect([...scale]..sort(), scale);
    });

    test('radii borders match their radius', () {
      expect(AppRadii.cardBorder.topLeft.x, AppRadii.card);
      expect(AppRadii.rowBorder.topLeft.x, AppRadii.row);
      expect(AppRadii.chipBorder.topLeft.x, AppRadii.chip);
      expect(AppRadii.pillBorder.topLeft.x, AppRadii.pill);
    });

    test('ease curve starts at 0 and ends at 1', () {
      expect(AppMotion.ease.transform(0), 0);
      expect(AppMotion.ease.transform(1), closeTo(1, 1e-6));
    });

    test('typography uses Poppins and mono uses tabular figures', () {
      expect(AppTypography.body.fontFamily, AppTypography.fontFamily);
      expect(AppTypography.mono.fontFeatures, isNotEmpty);
      expect(AppTypography.mono.fontFamilyFallback, AppTypography.monoFallback);
    });

    test('elevation tokens are non-empty and sizes are positive', () {
      expect(AppElevation.card, isNotEmpty);
      expect(AppElevation.dialog, isNotEmpty);
      expect(AppElevation.segment, isNotEmpty);
      expect(AppElevation.iconButton, isNotEmpty);
      expect(AppSizes.control, greaterThan(0));
    });

    test('stage colors are distinct', () {
      final colors = AppStage.values.map(AppStageDot.colorOf).toSet();
      expect(colors, hasLength(AppStage.values.length));
    });
  });
}
