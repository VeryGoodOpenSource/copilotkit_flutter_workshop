import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/test_skull_art.dart';

void main() {
  const calaverita = Calaverita(
    name: 'Ana',
    job: 'chef',
    tone: Tone.sarcastic,
    lines: ['one', 'two', 'three', 'four'],
  );

  Future<void> pumpCard(WidgetTester tester, {required bool showPortrait}) {
    return tester.pumpWidget(
      Provider<SkullArt>.value(
        value: TestSkullArt.build(),
        child: MaterialApp(
          home: Scaffold(
            body: CalaveritaCard(
              calaverita: calaverita,
              showPortrait: showPortrait,
            ),
          ),
        ),
      ),
    );
  }

  group(CalaveritaCard, () {
    testWidgets('shows the title, the subject and every line', (tester) async {
      await pumpCard(tester, showPortrait: true);

      expect(find.text('Calaverita for Ana'), findsOneWidget);
      expect(find.text('chef · Sarcastic'), findsOneWidget);
      for (final line in calaverita.lines) {
        expect(find.text(line), findsOneWidget);
      }
    });

    testWidgets('has the same opaque background on any surface', (
      tester,
    ) async {
      await pumpCard(tester, showPortrait: false);

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(CalaveritaCard),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.color!.a, 1);
    });

    testWidgets('shows the portrait unless asked not to', (tester) async {
      await pumpCard(tester, showPortrait: true);
      expect(find.byType(SkullView), findsOneWidget);

      await pumpCard(tester, showPortrait: false);
      expect(find.byType(SkullView), findsNothing);
    });
  });
}
