import 'package:calaverita_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('writes a calaverita from the form', (tester) async {
    await tester.pumpWidget(const App());

    await tester.enterText(
      find.byKey(const Key('calaverita_name_field')),
      'Ana',
    );
    await tester.enterText(
      find.byKey(const Key('calaverita_job_field')),
      'Designer',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('calaverita_generate_button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('💀 Calaverita for Ana'), findsOneWidget);
  });
}
