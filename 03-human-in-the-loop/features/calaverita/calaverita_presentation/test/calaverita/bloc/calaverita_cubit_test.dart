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
      'writes a calaverita for a complete draft',
      setUp: () =>
          when(() => repository.generate(any()))
              .thenAnswer((_) async => calaverita),
      build: build,
      act: (cubit) => cubit.generate(draft),
      expect: () => const [
        CalaveritaState(status: GenerationStatus.generating),
        CalaveritaState(
          status: GenerationStatus.success,
          calaverita: calaverita,
        ),
      ],
      verify: (_) => verify(() => repository.generate(draft)).called(1),
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'shows a calaverita the agent wrote',
      build: build,
      act: (cubit) => cubit.calaveritaShown(calaverita),
      expect: () => const [
        CalaveritaState(
          status: GenerationStatus.success,
          calaverita: calaverita,
        ),
      ],
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'does nothing while the draft is incomplete',
      build: build,
      act: (cubit) => cubit.generate(const CalaveritaDraft(name: 'Ana')),
      expect: () => const <CalaveritaState>[],
      verify: (_) => verifyNever(() => repository.generate(any())),
    );

    blocTest<CalaveritaCubit, CalaveritaState>(
      'fails when the repository throws',
      setUp: () =>
          when(() => repository.generate(any())).thenThrow(StateError('no')),
      build: build,
      act: (cubit) => cubit.generate(draft),
      errors: () => [isA<StateError>()],
      expect: () => const [
        CalaveritaState(status: GenerationStatus.generating),
        CalaveritaState(status: GenerationStatus.failure),
      ],
    );
  });
}
