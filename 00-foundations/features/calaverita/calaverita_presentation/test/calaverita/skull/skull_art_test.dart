import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita_presentation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_skull_art.dart';

void main() {
  group(SkullArt, () {
    final art = TestSkullArt.build();

    test('fills the colors into the template', () {
      final svg = art.svg(SkullArt.hat, 'sombrero')!;
      expect(svg, contains('fill="#e0353b"'));
      expect(svg, contains('stroke-width="4.0"'));
      expect(svg, isNot(contains('{{')));
    });

    test('draws a fixed piece whatever the variant', () {
      expect(art.svg(SkullArt.base.withFill('#12a5a0')), contains('#12a5a0'));
    });

    test('has no SVG for a variant it was not given', () {
      expect(art.svg(SkullArt.hat, 'crown'), isNull);
    });

    test('crops a thumbnail to where the part sits', () {
      final svg = art.thumbnail(
        SkullArt.glasses,
        'heart',
        SkullArt.focusOf(SkullPart.glasses),
      )!;
      expect(svg, contains('viewBox="60.0 160.0 280.0 110.0"'));
    });

    test('knows where every accessory sits', () {
      for (final part in SkullPart.values) {
        expect(SkullArt.focusOf(part), isNot(Rect.zero));
        expect(SkullArt.layerOf(part).kind, part.name);
      }
    });
  });
}
