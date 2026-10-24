import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  testWidgets('AppSkeleton pulses with a fixed width', (tester) async {
    await tester.pumpApp(const AppSkeleton(width: 40), settle: false);
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.getSize(find.byType(AppSkeleton)).width, 40);
  });

  testWidgets('AppSkeletonBlock renders one line per fraction', (tester) async {
    await tester.pumpApp(
      const SizedBox(width: 200, child: AppSkeletonBlock()),
      settle: false,
    );
    expect(find.byType(AppSkeleton), findsNWidgets(3));
  });
}
