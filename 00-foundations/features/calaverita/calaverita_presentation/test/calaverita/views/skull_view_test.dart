import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/test_skull_art.dart';

void main() {
  Future<void> pumpSkull(WidgetTester tester, SkullStyle style) {
    return tester.pumpWidget(
      Provider<SkullArt>.value(
        value: TestSkullArt.build(),
        child: MaterialApp(
          home: Scaffold(body: SkullView(style: style)),
        ),
      ),
    );
  }

  group(SkullView, () {
    testWidgets('draws the five fixed pieces on a plain skull', (tester) async {
      await pumpSkull(tester, const SkullStyle());

      expect(find.byType(SvgPicture), findsNWidgets(5));
    });

    testWidgets('adds what the skull wears', (tester) async {
      await pumpSkull(
        tester,
        const SkullStyle(hat: 'sombrero', glasses: 'heart'),
      );

      expect(find.byType(SvgPicture), findsNWidgets(7));
      expect(find.byKey(const ValueKey('hat')), findsOneWidget);
      expect(find.byKey(const ValueKey('glasses')), findsOneWidget);
    });

    testWidgets('skips an accessory it has no art for', (tester) async {
      await pumpSkull(tester, const SkullStyle(mustache: 'walrus'));

      expect(find.byType(SvgPicture), findsNWidgets(5));
    });
  });
}
