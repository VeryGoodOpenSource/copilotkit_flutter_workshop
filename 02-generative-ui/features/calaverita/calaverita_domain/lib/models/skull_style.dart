import 'package:calaverita_domain/models/skull_part.dart';
import 'package:equatable/equatable.dart';

/// How the sugar skull looks: its color and what it wears.
///
/// Each accessory is the id of one of its [SkullPart.variants], or
/// [SkullStyle.none].
class SkullStyle extends Equatable {
  const SkullStyle({
    this.color = defaultColor,
    this.hat = none,
    this.glasses = none,
    this.mustache = none,
    this.flowers = none,
  });

  /// Reads a style from JSON, ignoring unknown or invalid fields.
  factory SkullStyle.fromJson(Map<String, Object?> json) {
    String variant(SkullPart part) {
      final value = json[part.name];
      return value is String && part.variants.contains(value) ? value : none;
    }

    final color = json['color'];
    return SkullStyle(
      color: color is String && _hex.hasMatch(color)
          ? color.toLowerCase()
          : defaultColor,
      hat: variant(SkullPart.hat),
      glasses: variant(SkullPart.glasses),
      mustache: variant(SkullPart.mustache),
      flowers: variant(SkullPart.flowers),
    );
  }

  /// The id of an accessory the skull doesn't wear.
  static const none = 'none';

  /// Bone, the color of a plain skull.
  static const defaultColor = '#f6efe0';

  static final _hex = RegExp(r'^#[0-9a-fA-F]{6}$');

  /// The skull color, as `#rrggbb`.
  final String color;
  final String hat;
  final String glasses;
  final String mustache;
  final String flowers;

  /// The variant of [part] the skull wears, or [none].
  String of(SkullPart part) => switch (part) {
    SkullPart.hat => hat,
    SkullPart.glasses => glasses,
    SkullPart.mustache => mustache,
    SkullPart.flowers => flowers,
  };

  /// Returns this style with [part] set to [variant], or [none] to take it
  /// off.
  SkullStyle wearing(SkullPart part, String variant) => SkullStyle(
    color: color,
    hat: part == SkullPart.hat ? variant : hat,
    glasses: part == SkullPart.glasses ? variant : glasses,
    mustache: part == SkullPart.mustache ? variant : mustache,
    flowers: part == SkullPart.flowers ? variant : flowers,
  );

  SkullStyle withColor(String color) => SkullStyle(
    color: color,
    hat: hat,
    glasses: glasses,
    mustache: mustache,
    flowers: flowers,
  );

  Map<String, Object?> toJson() => {
    'color': color,
    for (final part in SkullPart.values) part.name: of(part),
  };

  @override
  List<Object?> get props => [color, hat, glasses, mustache, flowers];
}
