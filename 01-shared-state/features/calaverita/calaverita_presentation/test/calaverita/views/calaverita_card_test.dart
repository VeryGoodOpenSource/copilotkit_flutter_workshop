import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the title, the subject and every line', (tester) async {
    const calaverita = Calaverita(
      name: 'Ana',
      job: 'chef',
      tone: Tone.sarcastic,
      lines: ['one', 'two', 'three', 'four'],
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CalaveritaCard(calaverita: calaverita)),
      ),
    );

    expect(find.text('💀 Calaverita for Ana'), findsOneWidget);
    expect(find.text('chef · Sarcastic'), findsOneWidget);
    for (final line in calaverita.lines) {
      expect(find.text(line), findsOneWidget);
    }
  });
}
