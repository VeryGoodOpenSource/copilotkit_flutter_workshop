import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/skull/skull_art.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Draws the skull: its fixed pieces and the accessories it wears, stacked
/// bottom first.
///
/// It only reads [style], so it draws the same wherever it is: the stage, a
/// card in the chat. Needs a [SkullArt] above it.
class SkullView extends StatelessWidget {
  const SkullView({required this.style, super.key});

  final SkullStyle style;

  @override
  Widget build(BuildContext context) {
    final art = context.read<SkullArt>();
    final pieces = <(String, String?)>[
      ('base', art.svg(SkullArt.base.withFill(style.color))),
      ('pattern', art.svg(SkullArt.pattern)),
      ('eyes', art.svg(SkullArt.eyes)),
      ('nose', art.svg(SkullArt.nose)),
      _accessory(art, SkullPart.mustache),
      ('mouth', art.svg(SkullArt.mouth)),
      _accessory(art, SkullPart.glasses),
      _accessory(art, SkullPart.flowers),
      _accessory(art, SkullPart.hat),
    ];
    return AspectRatio(
      aspectRatio: 400 / 500,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final (key, svg) in pieces)
            if (svg != null) SvgPicture.string(svg, key: ValueKey(key)),
        ],
      ),
    );
  }

  (String, String?) _accessory(SkullArt art, SkullPart part) {
    final variant = style.of(part);
    return (
      part.name,
      variant == SkullStyle.none
          ? null
          : art.svg(SkullArt.layerOf(part), variant),
    );
  }
}
