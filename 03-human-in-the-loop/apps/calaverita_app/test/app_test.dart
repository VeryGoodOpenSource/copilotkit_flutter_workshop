import 'package:calaverita_app/app/app.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App(skullArt: SkullArt.fromTemplates({})));
    await tester.pump();
  }

  testWidgets('shows the details, the stage and the copilot', (tester) async {
    await pumpApp(tester);

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Copilot'), findsOneWidget);
    expect(find.byKey(const Key('calaverita_name_field')), findsOneWidget);
    expect(find.text('Write a calaverita for Mario, a chef'), findsOneWidget);
  });

  testWidgets('writes a calaverita from the details', (tester) async {
    await pumpApp(tester);

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

    expect(find.text('Calaverita for Ana'), findsOneWidget);
  });
}
