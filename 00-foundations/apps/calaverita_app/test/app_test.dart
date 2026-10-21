import 'package:calaverita_app/app/app.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('writes a calaverita from the details', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App(skullArt: SkullArt.fromTemplates({})));

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

  testWidgets('dresses the skull from the details', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App(skullArt: SkullArt.fromTemplates({})));

    await tester.tap(find.bySemanticsLabel('Hat sombrero'));
    await tester.pump();

    final selected = tester.getSemantics(find.bySemanticsLabel('Hat sombrero'));
    expect(selected.flagsCollection.isSelected.name, isNot('none'));
  });
}
