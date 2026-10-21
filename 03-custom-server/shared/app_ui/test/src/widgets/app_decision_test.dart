import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AppDecisionCard', () {
    testWidgets('renders header, diagnosis and children', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 360,
          child: AppDecisionCard(
            kindLabel: 'Incident',
            kindIcon: AppIcons.warning,
            title: 'Machine down',
            diagnosis: 'Grinder jammed.',
            trailing: AppSeverityChip(severity: AppSeverity.high),
            urgent: true,
            children: [Text('child')],
          ),
        ),
      );
      expect(find.text('Incident'), findsOneWidget);
      expect(find.text('Machine down'), findsOneWidget);
      expect(find.text('Grinder jammed.'), findsOneWidget);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('renders minimal and complete states', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 360,
          child: AppDecisionCard(
            kindLabel: 'Systemic',
            title: 'T',
            complete: true,
            children: [],
          ),
        ),
      );
      expect(find.text('Systemic'), findsOneWidget);
    });
  });

  group('AppDecisionCard loading', () {
    testWidgets('draws skeletons for a missing title and diagnosis', (
      tester,
    ) async {
      await tester.pumpApp(
        const SizedBox(
          width: 360,
          child: AppDecisionCard(
            kindLabel: 'Proposal',
            title: null,
            loading: true,
            children: [],
          ),
        ),
      );
      expect(find.byType(AppSkeleton), findsNWidgets(3));
    });

    testWidgets('keeps the arrived text and skeletons only the rest', (
      tester,
    ) async {
      await tester.pumpApp(
        const SizedBox(
          width: 360,
          child: AppDecisionCard(
            kindLabel: 'Proposal',
            title: 'Machine down',
            loading: true,
            children: [],
          ),
        ),
      );
      expect(find.text('Machine down'), findsOneWidget);
      expect(find.byType(AppSkeleton), findsNWidgets(2));
    });

    testWidgets('leaves missing text out when not loading', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 360,
          child: AppDecisionCard(
            kindLabel: 'Proposal',
            title: null,
            children: [],
          ),
        ),
      );
      expect(find.byType(AppSkeleton), findsNothing);
    });
  });

  group('AppOptionTile', () {
    testWidgets('shows details and handles taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        SizedBox(
          width: 360,
          child: AppOptionTile(
            label: 'Add courier',
            detail: 'Faster',
            cost: r'$12',
            recommended: true,
            selected: true,
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('RECOMMENDED'), findsOneWidget);
      expect(find.text(r'$12'), findsOneWidget);
      await tester.tap(find.byType(AppOptionTile));
      expect(taps, 1);
    });

    testWidgets('is dimmed when read-only and unselected', (tester) async {
      await tester.pumpApp(const AppOptionTile(label: 'Skip'));
      expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 0.7);
    });
  });
}
