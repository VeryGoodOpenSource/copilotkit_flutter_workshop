import 'package:bloc_test/bloc_test.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ICalaveritasRepository;

void main() {
  const draft = CalaveritaDraft(name: 'Ana', job: 'Chef');
  const calaverita = Calaverita(
    name: 'Ana',
    job: 'chef',
    tone: Tone.playful,
    lines: ['a', 'b', 'c', 'd'],
  );

  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(draft));
  setUp(() => repository = _MockRepository());

  CalaveritaCubit build() => CalaveritaCubit(calaveritasRepository: repository);

  group(CalaveritaCubit, () {
    blocTest<CalaveritaCubit, CalaveritaState>(
      'edits the draft',
      build: build,
      act: (cubit) => cubit
        ..nameChanged('Ana')
        ..jobChanged('Chef')
        ..toneChanged(Tone.dramatic),
      expect: () => const [
        CalaveritaState(draft: CalaveritaDraft(name: 'Ana')),
        CalaveritaState(
          draft: CalaveritaDraft(name: 'Ana', job: 'Chef'),
        ),
        CalaveritaState(
          draft: CalaveritaDraft(name: 'Ana', job: 'Chef', tone: Tone.dramatic),
        ),
      ],
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'dresses and paints the skull',
      build: build,
      act: (cubit) => cubit
        ..skullPartChanged(SkullPart.hat, 'sombrero')
        ..skullColorChanged('#12a5a0')
        ..skullPartChanged(SkullPart.hat, SkullStyle.none),
      expect: () => const [
        CalaveritaState(
          draft: CalaveritaDraft(skull: SkullStyle(hat: 'sombrero')),
        ),
        CalaveritaState(
          draft: CalaveritaDraft(
            skull: SkullStyle(color: '#12a5a0', hat: 'sombrero'),
          ),
        ),
        CalaveritaState(
          draft: CalaveritaDraft(skull: SkullStyle(color: '#12a5a0')),
        ),
      ],
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'writes a calaverita for a complete draft',
      setUp: () =>
          when(() => repository.generate(any()))
              .thenAnswer((_) async => calaverita),
      build: build,
      seed: () => const CalaveritaState(draft: draft),
      act: (cubit) => cubit.generate(),
      expect: () => const [
        CalaveritaState(draft: draft, status: GenerationStatus.generating),
        CalaveritaState(
          draft: draft,
          status: GenerationStatus.success,
          calaverita: calaverita,
        ),
      ],
      verify: (_) => verify(() => repository.generate(draft)).called(1),
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'does nothing while the draft is incomplete',
      build: build,
      act: (cubit) => cubit.generate(),
      expect: () => const <CalaveritaState>[],
      verify: (_) => verifyNever(() => repository.generate(any())),
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'fails when the repository throws',
      setUp: () =>
          when(() => repository.generate(any())).thenThrow(StateError('no')),
      build: build,
      seed: () => const CalaveritaState(draft: draft),
      act: (cubit) => cubit.generate(),
      errors: () => [isA<StateError>()],
      expect: () => const [
        CalaveritaState(draft: draft, status: GenerationStatus.generating),
        CalaveritaState(draft: draft, status: GenerationStatus.failure),
      ],
    );
  });
}
