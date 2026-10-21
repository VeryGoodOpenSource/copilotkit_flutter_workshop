import 'dart:convert';

import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_args.dart';
import 'package:calaverita_presentation/calaverita/show_calaverita/show_calaverita_handler.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const args = ShowCalaveritaArgs(lines: ['one', 'two', 'three', 'four']);

  Future<String> run(CalaveritaDraft draft, ShowCalaveritaArgs args) =>
      ShowCalaveritaHandler(readDraft: () => draft)
          .handle(args, signal: CancellationSignal());

  group(ShowCalaveritaHandler, () {
    test('puts the verse together with the form and the skull', () async {
      final result = await run(
        const CalaveritaDraft(
          name: ' Ana ',
          job: 'Pilot',
          tone: Tone.sarcastic,
          skull: SkullStyle(hat: 'crown'),
        ),
        args,
      );

      expect(
        Calaverita.fromJson(jsonDecode(result) as Map<String, Object?>),
        const Calaverita(
          name: 'Ana',
          job: 'pilot',
          tone: Tone.sarcastic,
          lines: ['one', 'two', 'three', 'four'],
          skull: SkullStyle(hat: 'crown'),
        ),
      );
    });

    test('says so when the form is incomplete', () async {
      final result = await run(const CalaveritaDraft(name: 'Ana'), args);

      expect(result, contains('name and a job'));
    });

    test('says so when there is no verse', () async {
      final result = await run(
        const CalaveritaDraft(name: 'Ana', job: 'Pilot'),
        const ShowCalaveritaArgs(),
      );

      expect(result, contains('no verse'));
    });
  });

  group(ShowCalaveritaArgs, () {
    test('reads the lines and ignores what is not text', () {
      final args = ShowCalaveritaArgs.fromJson(const {
        'lines': ['one', 2, 'three'],
      });

      expect(args.lines, ['one', 'three']);
      expect(ShowCalaveritaArgs.fromJson(const {}).lines, isEmpty);
    });
  });
}
