import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/views/calaverita_form.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ICalaveritasRepository;

void main() {
  const agentId = 'default';
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(const CalaveritaDraft()));
  setUp(() => repository = _MockRepository());

  Future<CopilotAgent> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in these tests runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: MaterialApp(
          home: CopilotAgentScope(
            agentId: agentId,
            child: BlocProvider(
              create: (_) => CalaveritaCubit(calaveritasRepository: repository),
              child: const Scaffold(body: CalaveritaForm()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return CopilotKit.of(tester.element(find.byType(CalaveritaForm)))
        .agent(agentId);
  }

  /// Lets the agent's stream deliver its last state, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(pumpEventQueue);
    await tester.pump();
  }

  Map<String, Object?>? shared(CopilotAgent agent) =>
      agent.state.sharedState?.toJson();

  String textOf(WidgetTester tester, String key) => tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ),
      )
      .controller!
      .text;

  group(CalaveritaForm, () {
    testWidgets('shares the empty form with the agent', (tester) async {
      final agent = await pumpForm(tester);

      expect(shared(agent), {'name': '', 'job': '', 'tone': 'playful'});
    });

    testWidgets('shows what the agent writes into the shared state', (
      tester,
    ) async {
      final agent = await pumpForm(tester);

      agent.patchSharedState(const [
        StatePatchReplace(path: '/name', value: 'Ana'),
        StatePatchReplace(path: '/job', value: 'Chef'),
        StatePatchReplace(path: '/tone', value: 'sarcastic'),
      ]);
      await settle(tester);

      expect(textOf(tester, 'calaverita_name_field'), 'Ana');
      expect(textOf(tester, 'calaverita_job_field'), 'Chef');
      final tones = tester.widget<SegmentedButton<Tone>>(
        find.byKey(const Key('calaverita_tone_selector')),
      );
      expect(tones.selected, {Tone.sarcastic});
    });

    testWidgets('shows a snapshot the agent sends', (tester) async {
      final agent = await pumpForm(tester);

      agent.setSharedState(
        const SharedState({'name': 'Luz', 'job': 'Pilot', 'tone': 'dramatic'}),
      );
      await settle(tester);

      expect(textOf(tester, 'calaverita_name_field'), 'Luz');
      expect(textOf(tester, 'calaverita_job_field'), 'Pilot');
    });

    testWidgets('writes what the person types into the shared state', (
      tester,
    ) async {
      final agent = await pumpForm(tester);

      await tester.enterText(
        find.byKey(const Key('calaverita_name_field')),
        'Ana',
      );
      await tester.tap(find.text('Dramatic'));
      await tester.pump();

      expect(shared(agent), {'name': 'Ana', 'job': '', 'tone': 'dramatic'});
    });

    testWidgets('writes the calaverita for the shared draft', (tester) async {
      when(() => repository.generate(any())).thenAnswer(
        (_) async => const Calaverita(
          name: 'Ana',
          job: 'chef',
          tone: Tone.playful,
          lines: [],
        ),
      );
      final agent = await pumpForm(tester);
      agent.setSharedState(
        const SharedState({'name': 'Ana', 'job': 'Chef', 'tone': 'playful'}),
      );
      await settle(tester);

      await tester.tap(find.byKey(const Key('calaverita_generate_button')));
      await settle(tester);

      verify(
        () => repository.generate(
          const CalaveritaDraft(name: 'Ana', job: 'Chef'),
        ),
      ).called(1);
    });
  });
}
