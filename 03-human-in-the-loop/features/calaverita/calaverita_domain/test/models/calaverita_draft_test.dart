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
        skull: SkullStyle(color: '#12a5a0', hat: 'sombrero', flowers: 'trio'),
      );
      expect(CalaveritaDraft.fromJson(draft.toJson()), draft);
    });

    test('ignores invalid JSON fields', () {
      final draft = CalaveritaDraft.fromJson(const {
        'name': 42,
        'job': 'Chef',
        'tone': 'grumpy',
        'skull': {'hat': 'helmet', 'color': 'red', 'glasses': 'heart'},
      });
      expect(
        draft,
        const CalaveritaDraft(
          job: 'Chef',
          skull: SkullStyle(glasses: 'heart'),
        ),
      );
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
