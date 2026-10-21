import 'package:app_ui/app_ui.dart';
import 'package:calaverita_domain/calaverita_domain.dart';
import 'package:calaverita_presentation/calaverita/skull/skull_art.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// What the person can do to the skull: take an accessory off or put one on,
/// and paint it.
class SkullControls extends StatelessWidget {
  const SkullControls({
    required this.style,
    required this.onPartChanged,
    required this.onColorChanged,
    super.key,
  });

  final SkullStyle style;
  final void Function(SkullPart part, String variant) onPartChanged;
  final ValueChanged<String> onColorChanged;

  /// Bone, white and the festive colors of the art.
  static const swatches = {
    '#f6efe0': 'Bone',
    '#ffffff': 'White',
    '#12a5a0': 'Teal',
    '#1fa567': 'Green',
    '#f5a524': 'Marigold',
    '#ff8fb1': 'Pink',
    '#8fa8ff': 'Sky',
    '#7048e8': 'Violet',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xl,
      children: [
        for (final part in SkullPart.values)
          _PartPicker(
            part: part,
            selected: style.of(part),
            onChanged: (variant) => onPartChanged(part, variant),
          ),
        _ColorPicker(value: style.color, onChanged: onColorChanged),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.smallMedium.copyWith(
      color: context.palette.inkSecondary,
    ),
  );
}

class _PartPicker extends StatelessWidget {
  const _PartPicker({
    required this.part,
    required this.selected,
    required this.onChanged,
  });

  final SkullPart part;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        _Label(part.label),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final variant in [SkullStyle.none, ...part.variants])
              _Option(
                part: part,
                variant: variant,
                selected: variant == selected,
                onTap: () => onChanged(variant),
              ),
          ],
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.part,
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final SkullPart part;
  final String variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final art = context.read<SkullArt>();
    final svg = variant == SkullStyle.none
        ? null
        : art.thumbnail(
            SkullArt.layerOf(part),
            variant,
            SkullArt.focusOf(part),
          );
    return Semantics(
      button: true,
      selected: selected,
      label: '${part.label} $variant',
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.97,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          width: 62,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? p.accentWash : p.cardGround,
            borderRadius: BorderRadius.circular(AppRadii.option),
            border: Border.all(
              color: selected ? p.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            spacing: AppSpacing.xs,
            children: [
              SizedBox(
                height: 44,
                child: svg == null
                    ? Icon(Icons.block, color: p.inkTertiary)
                    : SvgPicture.string(svg),
              ),
              Text(
                variant == SkullStyle.none ? 'None' : variant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.micro.copyWith(color: p.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        const _Label('Skull color'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final MapEntry(key: hex, value: name)
                in SkullControls.swatches.entries)
              Semantics(
                button: true,
                label: name,
                selected: hex == value,
                child: GestureDetector(
                  onTap: () => onChanged(hex),
                  child: AnimatedContainer(
                    duration: AppMotion.quick,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse('ff${hex.substring(1)}', radix: 16),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hex == value ? p.accent : p.hairline,
                        width: hex == value ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
