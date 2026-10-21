import 'package:calaverita_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the form next to the chat', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.byKey(const Key('calaverita_name_field')), findsOneWidget);
    expect(find.byKey(const Key('chat_input')), findsOneWidget);
    expect(find.byKey(const Key('shared_state_inspector')), findsOneWidget);
  });

  testWidgets('writes a calaverita from the form', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1200, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pump();

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
