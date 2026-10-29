import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/draft_edits.dart';
import 'package:calaverita_presentation/calaverita/shared_draft/shared_draft.dart';
import 'package:copilotkit_flutter/copilotkit_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agentId = 'default';
  late DraftEdits edits;
  late CopilotAgent agent;
  CalaveritaDraft? shown;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(pumpEventQueue);
    await tester.pump();
  }

  Future<void> pumpScope(WidgetTester tester) async {
    shown = null;
    await tester.pumpWidget(
      CopilotKit(
        // Never called: nothing in these tests runs the agent.
        runtimeUrl: Uri.parse('http://localhost:1/api/copilotkit'),
        child: MaterialApp(
          home: CopilotAgentScope(
            agentId: agentId,
            child: SharedDraft(
              builder: (context, draft) {
                shown = draft;
                edits = DraftEdits.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    agent = CopilotKit.of(tester.element(find.byType(SizedBox))).agent(agentId);
  }

  Map<String, Object?>? shared() => agent.state.sharedState?.toJson();

  group(DraftEdits, () {
    testWidgets('shares the empty form once', (tester) async {
      await pumpScope(tester);
      expect(shared(), isNull);

      edits.ensureInitialized();
      expect(shared(), const CalaveritaDraft().toJson());

      edits
        ..nameChanged('Ana')
        ..ensureInitialized();
      expect(shared()!['name'], 'Ana');
    });

    testWidgets('patches one field at a time', (tester) async {
      await pumpScope(tester);
      edits
        ..ensureInitialized()
        ..nameChanged('Ana')
        ..jobChanged('Pilot')
        ..toneChanged(Tone.sarcastic)
        ..skullPartChanged(SkullPart.hat, 'sombrero')
        ..skullColorChanged('#12a5a0');

      expect(
        shared(),
        const CalaveritaDraft(
          name: 'Ana',
          job: 'Pilot',
          tone: Tone.sarcastic,
          skull: SkullStyle(color: '#12a5a0', hat: 'sombrero'),
        ).toJson(),
      );
    });

    testWidgets('recovers when the agent shares a state without the path', (
      tester,
    ) async {
      await pumpScope(tester);
      agent.setSharedState(const SharedState({'name': 'Luz'}));

      edits.skullPartChanged(SkullPart.glasses, 'heart');

      expect(
        shared(),
        const CalaveritaDraft(
          name: 'Luz',
          skull: SkullStyle(glasses: 'heart'),
        ).toJson(),
      );
    });

    testWidgets('resets the form', (tester) async {
      await pumpScope(tester);
      edits
        ..nameChanged('Ana')
        ..reset();

      expect(shared(), const CalaveritaDraft().toJson());
    });
  });

  group(SharedDraft, () {
    testWidgets('shows an empty draft while nothing is shared', (tester) async {
      await pumpScope(tester);

      expect(shown, const CalaveritaDraft());
    });

    testWidgets('shows what the agent shares', (tester) async {
      await pumpScope(tester);

      agent.patchSharedState(const [
        StatePatchAdd(path: '/name', value: 'Ana'),
        StatePatchAdd(path: '/skull', value: {'hat': 'crown'}),
      ]);
      await settle(tester);

      expect(
        shown,
        const CalaveritaDraft(
          name: 'Ana',
          skull: SkullStyle(hat: 'crown'),
        ),
      );
    });

    testWidgets('shows a snapshot of the agent', (tester) async {
      await pumpScope(tester);

      agent.setSharedState(
        const SharedState({'name': 'Luz', 'job': 'Pilot', 'tone': 'dramatic'}),
      );
      await settle(tester);

      expect(
        shown,
        const CalaveritaDraft(name: 'Luz', job: 'Pilot', tone: Tone.dramatic),
      );
    });
  });
}
