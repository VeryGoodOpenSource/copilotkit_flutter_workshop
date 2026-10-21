import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

/// Widgets are usually built with `const`, which never runs the constructor.
/// Building them from runtime values keeps constructor lines covered and
/// proves non-const usage works.
void main() {
  testWidgets('widgets build from runtime values', (tester) async {
    final n = DateTime.now().millisecond;
    final label = 'v$n';
    await tester.pumpApp(
      SizedBox(
        width: 400,
        child: Column(
          children: [
            AppUnicorn(size: 10 + n * 0),
            AppVgvLockup(height: 10 + n * 0),
            AppCountBadge(count: n),
            AppStageDot(stage: AppStage.values[n % 4]),
            AppDecisionCard(kindLabel: label, title: label, children: const []),
            AppDialogStep(text: label),
            AppAvatar(name: label),
            AppPersonRow(name: label, caption: label, meter: 0.5),
            AppSkeleton(width: 10 + n * 0.0),
            AppStatTile(label: label, value: label),
            AppKeyValueRow(label: label, value: label),
            AppToast(message: label),
            AppStepPill(number: n, label: label, state: AppStepState.now),
            AppSkeletonBlock(fractions: [0.5 + n * 0]),
            AppGoalChip(strong: label, label: label),
          ],
        ),
      ),
      settle: false,
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AppToast), findsOneWidget);
  });
}
