import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:test/test.dart';

void main() {
  group(CalaveritaDraft, () {
    test('is incomplete until it has a name and a job', () {
      expect(const CalaveritaDraft().isComplete, isFalse);
      expect(const CalaveritaDraft(name: 'Ana').isComplete, isFalse);
      expect(const CalaveritaDraft(name: 'Ana', job: ' ').isComplete, isFalse);
      expect(
        const CalaveritaDraft(name: 'Ana', job: 'Designer').isComplete,
        isTrue,
      );
    });

    test('round-trips through JSON', () {
      const draft = CalaveritaDraft(
        name: 'Ana',
        job: 'Designer',
        tone: Tone.sarcastic,
      );
      expect(CalaveritaDraft.fromJson(draft.toJson()), draft);
    });

    test('ignores invalid JSON fields', () {
      final draft = CalaveritaDraft.fromJson(const {
        'name': 42,
        'job': 'Chef',
        'tone': 'grumpy',
      });
      expect(draft, const CalaveritaDraft(job: 'Chef'));
    });

    test('copyWith keeps what it is not given', () {
      const draft = CalaveritaDraft(name: 'Ana', job: 'Chef');
      expect(
        draft.copyWith(tone: Tone.dramatic),
        const CalaveritaDraft(name: 'Ana', job: 'Chef', tone: Tone.dramatic),
      );
    });
  });
}
