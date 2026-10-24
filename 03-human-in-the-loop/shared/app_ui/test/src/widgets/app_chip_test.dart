import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppChip', () {
    testWidgets('renders every tone with and without icon', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            for (final tone in AppTone.values)
              AppChip(label: tone.name, tone: tone),
            const AppChip(label: 'icon', icon: AppIcons.coffee),
            const AppChip(
              label: 'custom',
              foreground: AppColors.navy,
              background: AppColors.ground,
            ),
          ],
        ),
      );
      expect(find.byType(AppChip), findsNWidgets(AppTone.values.length + 2));
      expect(find.byType(AppIcon), findsOneWidget);
    });
  });

  group('AppVerdictChip', () {
    testWidgets('shows default labels and accepts overrides', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            for (final v in AppVerdict.values) AppVerdictChip(verdict: v),
            const AppVerdictChip(verdict: AppVerdict.approve, label: 'Yes'),
          ],
        ),
      );
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Edited'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });
  });

  group('AppSeverityChip', () {
    testWidgets('shows default labels and accepts overrides', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            for (final s in AppSeverity.values) AppSeverityChip(severity: s),
            const AppSeverityChip(severity: AppSeverity.low, label: 'Meh'),
          ],
        ),
      );
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Meh'), findsOneWidget);
    });
  });

  testWidgets('AppCountBadge shows the count', (tester) async {
    await tester.pumpApp(const AppCountBadge(count: 7));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('AppStageDot paints the stage color', (tester) async {
    await tester.pumpApp(
      Column(
        children: [for (final s in AppStage.values) AppStageDot(stage: s)],
      ),
    );
    expect(find.byType(AppStageDot), findsNWidgets(4));
  });

  group('AppStepPill', () {
    testWidgets('renders the three states', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            AppStepPill(number: 1, label: 'Past', state: AppStepState.past),
            AppStepPill(number: 2, label: 'Now', state: AppStepState.now),
            AppStepPill(number: 3, label: 'Next', state: AppStepState.upcoming),
          ],
        ),
      );
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.byType(AppIcon), findsOneWidget);
    });
  });
}
