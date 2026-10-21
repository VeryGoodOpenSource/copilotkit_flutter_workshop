import 'package:calaverita_presentation/calaverita_presentation.dart';

/// A few one-rectangle SVGs, enough to tell which pieces are drawn.
class TestSkullArt {
  const TestSkullArt._();

  static String _svg(String id) => [
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500"',
    ' width="400" height="500">',
    '<rect id="$id" width="10" height="10" fill="{{fill}}"',
    ' stroke="{{stroke}}" stroke-width="{{strokeWidth}}"/>',
    '<circle fill="{{accent}}" r="1"/></svg>',
  ].join();

  static SkullArt build() => SkullArt.fromTemplates({
    for (final path in [
      'base/round',
      'pattern/swirls',
      'eyes/marigold',
      'nose/heart',
      'mouth/stitched',
      'hat/sombrero',
      'glasses/heart',
    ])
      path: _svg(path.replaceAll('/', '-')),
  });
}
