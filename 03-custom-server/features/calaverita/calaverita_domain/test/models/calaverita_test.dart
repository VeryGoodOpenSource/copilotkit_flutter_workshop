import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:test/test.dart';

void main() {
  group(Calaverita, () {
    test('round-trips through JSON', () {
      const calaverita = Calaverita(
        name: 'Ana',
        job: 'pilot',
        tone: Tone.sarcastic,
        lines: ['one', 'two', 'three', 'four'],
        skull: SkullStyle(hat: 'crown', color: '#12a5a0'),
      );
      expect(Calaverita.fromJson(calaverita.toJson()), calaverita);
    });

    test('ignores invalid JSON fields', () {
      final calaverita = Calaverita.fromJson(const {
        'name': 7,
        'job': 'chef',
        'tone': 'grumpy',
        'lines': ['one', 2, 'three'],
        'skull': 'round',
      });
      expect(
        calaverita,
        const Calaverita(
          name: '',
          job: 'chef',
          tone: Tone.playful,
          lines: ['one', 'three'],
        ),
      );
    });
  });
}
