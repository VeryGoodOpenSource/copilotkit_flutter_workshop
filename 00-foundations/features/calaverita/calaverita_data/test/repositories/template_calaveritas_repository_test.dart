import 'package:calaverita_data/calaverita_data.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:test/test.dart';

void main() {
  group(TemplateCalaveritasRepository, () {
    const repository = TemplateCalaveritasRepository(delay: Duration.zero);

    test('fills the name and the job into every line', () async {
      final calaverita = await repository.generate(
        const CalaveritaDraft(name: 'Ana', job: 'Designer'),
      );
      expect(calaverita.lines, hasLength(4));
      final text = calaverita.lines.join('\n');
      expect(text, contains('Ana'));
      expect(text, contains('designer'));
      expect(text, isNot(contains('{')));
    });

    test('writes the same verse for the same draft', () async {
      const draft = CalaveritaDraft(name: 'Ana', job: 'Chef');
      expect(
        await repository.generate(draft),
        await repository.generate(draft),
      );
    });

    test('writes a verse for every tone', () async {
      for (final tone in Tone.values) {
        final calaverita = await repository.generate(
          CalaveritaDraft(name: 'Ana', job: 'Chef', tone: tone),
        );
        expect(calaverita.tone, tone);
        expect(calaverita.lines, hasLength(4));
      }
    });

    test('rejects an incomplete draft', () {
      expect(
        () => repository.generate(const CalaveritaDraft(name: 'Ana')),
        throwsArgumentError,
      );
    });
  });
}
