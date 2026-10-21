import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:flutter/services.dart';

/// One piece of the skull: which SVG it draws and in which colors.
///
/// Each SVG is a template: `{{fill}}`, `{{stroke}}`, `{{strokeWidth}}` and
/// `{{accent}}` are replaced with the colors below.
class SkullLayer {
  const SkullLayer(
    this.kind, {
    required this.fill,
    this.stroke = '#191817',
    this.strokeWidth = 3,
    this.accent = '#191817',
  });

  /// The folder of the SVGs, e.g. `hat`.
  final String kind;
  final String fill;
  final String stroke;
  final double strokeWidth;
  final String accent;

  /// Returns this layer with [fill] as its main color.
  SkullLayer withFill(String fill) => SkullLayer(
    kind,
    fill: fill,
    stroke: stroke,
    strokeWidth: strokeWidth,
    accent: accent,
  );
}

/// The SVGs of the skull, loaded once at startup so a piece draws the moment
/// its look changes.
class SkullArt {
  /// Creates the art from SVG `templates`, keyed by `kind/variant`.
  const SkullArt.fromTemplates(this._templates);

  /// Loads every SVG the skull can use.
  static Future<SkullArt> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    final templates = <String, String>{};
    for (final path in _paths) {
      templates[path] = await assets.loadString(
        'packages/calaverita_presentation/assets/skull/$path.svg',
      );
    }
    return SkullArt.fromTemplates(templates);
  }

  /// The pieces of the skull that never change.
  static const base = SkullLayer(
    'base',
    fill: '#f6efe0',
    strokeWidth: 5,
    accent: '#ff8fb1',
  );
  static const pattern = SkullLayer(
    'pattern',
    fill: '#d6336c',
    strokeWidth: 0,
    accent: '#f5a524',
  );
  static const eyes = SkullLayer('eyes', fill: '#191817', accent: '#f5a524');
  static const nose = SkullLayer('nose', fill: '#191817', strokeWidth: 2);
  static const mouth = SkullLayer(
    'mouth',
    fill: '#191817',
    strokeWidth: 4,
    accent: '#f6efe0',
  );

  /// How each accessory is colored.
  static const hat = SkullLayer(
    'hat',
    fill: '#e0353b',
    strokeWidth: 4,
    accent: '#f5a524',
  );
  static const glasses = SkullLayer(
    'glasses',
    fill: '#8fa8ff',
    strokeWidth: 5,
    accent: '#ffffff',
  );
  static const mustache = SkullLayer(
    'mustache',
    fill: '#2b1d3a',
    strokeWidth: 2,
  );
  static const flowers = SkullLayer(
    'flowers',
    fill: '#f5a524',
    strokeWidth: 2,
    accent: '#d6336c',
  );

  /// How [part] is colored.
  static SkullLayer layerOf(SkullPart part) => switch (part) {
    SkullPart.hat => hat,
    SkullPart.glasses => glasses,
    SkullPart.mustache => mustache,
    SkullPart.flowers => flowers,
  };

  /// The rectangle of the 400 x 500 canvas where [part] sits.
  static Rect focusOf(SkullPart part) => switch (part) {
    SkullPart.hat => const Rect.fromLTWH(10, 0, 380, 110),
    SkullPart.glasses => const Rect.fromLTWH(60, 160, 280, 110),
    SkullPart.mustache => const Rect.fromLTWH(115, 295, 170, 50),
    SkullPart.flowers => const Rect.fromLTWH(20, 40, 360, 130),
  };

  /// The variant of each fixed piece.
  static const _fixed = {
    'base': 'round',
    'pattern': 'swirls',
    'eyes': 'marigold',
    'nose': 'heart',
    'mouth': 'stitched',
  };

  static const _paths = [
    'base/round',
    'pattern/swirls',
    'eyes/marigold',
    'nose/heart',
    'mouth/stitched',
    'hat/sombrero',
    'hat/tophat',
    'hat/party',
    'hat/crown',
    'glasses/round',
    'glasses/square',
    'glasses/cateye',
    'glasses/heart',
    'mustache/handlebar',
    'mustache/walrus',
    'mustache/pencil',
    'flowers/crown',
    'flowers/side',
    'flowers/trio',
  ];

  final Map<String, String> _templates;

  /// The SVG of [layer] in [variant], or `null` when there is none.
  ///
  /// A fixed piece ignores [variant].
  String? svg(SkullLayer layer, [String? variant]) {
    final template =
        _templates['${layer.kind}/${_fixed[layer.kind] ?? variant}'];
    if (template == null) return null;
    return template
        .replaceAll('{{fill}}', layer.fill)
        .replaceAll('{{stroke}}', layer.stroke)
        .replaceAll('{{strokeWidth}}', layer.strokeWidth.toStringAsFixed(1))
        .replaceAll('{{accent}}', layer.accent);
  }

  /// Like [svg], cropped to [crop], a rectangle of the 400 x 500 canvas.
  String? thumbnail(SkullLayer layer, String variant, Rect crop) {
    final out = svg(layer, variant);
    return out?.replaceFirst(
      RegExp('viewBox="[^"]*" width="[^"]*" height="[^"]*"'),
      'viewBox="${crop.left} ${crop.top} ${crop.width} ${crop.height}"',
    );
  }
}
