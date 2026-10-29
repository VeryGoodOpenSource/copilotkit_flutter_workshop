import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_skull_art.dart';

class _MockRepository extends Mock implements ICalaveritasRepository;

void main() {
  const agentId = 'default';
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(const CalaveritaDraft()));
  setUp(() => repository = _MockRepository());

  /// Lets the agent's stream deliver its last state, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(pumpEventQueue);
    await tester.pump();
  }

  Future<CopilotAgent> pumpPage(WidgetTester tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in these tests runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: MaterialApp(
          home: CopilotAgentScope(
            agentId: agentId,
            child: CalaveritaModule(
              calaveritasRepository: repository,
              skullArt: TestSkullArt.build(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return CopilotKit.of(tester.element(find.byType(CalaveritaModule)))
        .agent(agentId);
  }

  String textOf(WidgetTester tester, String key) => tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ),
      )
      .controller!
      .text;

  group(CalaveritaModule, () {
    testWidgets('shares the empty form with the agent', (tester) async {
      final agent = await pumpPage(tester);

      expect(
        agent.state.sharedState?.toJson(),
        const CalaveritaDraft().toJson(),
      );
    });

    testWidgets('fills the details from what the agent shares', (tester) async {
      final agent = await pumpPage(tester);

      agent.patchSharedState(const [
        StatePatchReplace(path: '/name', value: 'Ana'),
        StatePatchReplace(path: '/job', value: 'Chef'),
        StatePatchReplace(path: '/skull/hat', value: 'sombrero'),
      ]);
      await settle(tester);

      expect(textOf(tester, 'calaverita_name_field'), 'Ana');
      expect(textOf(tester, 'calaverita_job_field'), 'Chef');
      expect(find.byKey(const ValueKey('hat')), findsOneWidget);
    });

    testWidgets('writes what the person types into the shared state', (
      tester,
    ) async {
      final agent = await pumpPage(tester);

      await tester.enterText(
        find.byKey(const Key('calaverita_name_field')),
        'Ana',
      );
      await tester.tap(find.bySemanticsLabel('Glasses heart'));
      await tester.pump();

      expect(agent.state.sharedState!.toJson(), {
        ...const CalaveritaDraft().toJson(),
        'name': 'Ana',
        'skull': const SkullStyle(glasses: 'heart').toJson(),
      });
    });

    testWidgets('writes the calaverita for the shared draft', (tester) async {
      when(() => repository.generate(any())).thenAnswer(
        (_) async => const Calaverita(
          name: 'Ana',
          job: 'chef',
          tone: Tone.playful,
          lines: ['one', 'two', 'three', 'four'],
        ),
      );
      final agent = await pumpPage(tester);
      agent.patchSharedState(const [
        StatePatchReplace(path: '/name', value: 'Ana'),
        StatePatchReplace(path: '/job', value: 'Chef'),
      ]);
      await settle(tester);

      await tester.tap(find.byKey(const Key('calaverita_generate_button')));
      await settle(tester);

      verify(
        () => repository.generate(
          const CalaveritaDraft(name: 'Ana', job: 'Chef'),
        ),
      ).called(1);
      expect(find.text('Calaverita for Ana'), findsOneWidget);
    });
  });
}
