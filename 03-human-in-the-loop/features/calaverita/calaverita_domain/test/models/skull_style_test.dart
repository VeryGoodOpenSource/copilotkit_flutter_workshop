import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:test/test.dart';

void main() {
  group(SkullStyle, () {
    test('starts plain', () {
      const style = SkullStyle();
      for (final part in SkullPart.values) {
        expect(style.of(part), SkullStyle.none);
      }
      expect(style.color, SkullStyle.defaultColor);
    });

    test('wears one accessory at a time', () {
      final style = const SkullStyle().wearing(SkullPart.hat, 'sombrero');
      expect(style.hat, 'sombrero');
      expect(style.glasses, SkullStyle.none);
      expect(style.wearing(SkullPart.hat, SkullStyle.none), const SkullStyle());
    });

    test('keeps the accessories when the color changes', () {
      final style = const SkullStyle(hat: 'party').withColor('#12a5a0');
      expect(style.hat, 'party');
      expect(style.color, '#12a5a0');
    });

    test('round-trips through JSON', () {
      const style = SkullStyle(color: '#d6336c', glasses: 'cateye');
      expect(SkullStyle.fromJson(style.toJson()), style);
    });

    test('ignores unknown variants and invalid colors', () {
      final style = SkullStyle.fromJson(const {
        'color': 'pink',
        'hat': 'helmet',
        'mustache': 'walrus',
      });
      expect(style, const SkullStyle(mustache: 'walrus'));
    });

    test('keeps a valid color in lower case', () {
      expect(SkullStyle.fromJson(const {'color': '#F5A524'}).color, '#f5a524');
    });
  });
}
