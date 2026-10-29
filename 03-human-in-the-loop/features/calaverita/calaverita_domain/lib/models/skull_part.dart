/// An accessory the skull can wear, and the looks it comes in.
///
/// Keep the variants in step with the SVGs of `calaverita_presentation` and
/// with the prompt of the runtime.
enum SkullPart {
  hat('Hat', ['sombrero', 'tophat', 'party', 'crown']),
  glasses('Glasses', ['round', 'square', 'cateye', 'heart']),
  mustache('Mustache', ['handlebar', 'walrus', 'pencil']),
  flowers('Flowers', ['crown', 'side', 'trio']);

  SkullPart(this.label, this.variants);

  /// The name shown to people.
  final String label;

  /// The looks of this accessory, besides `none`.
  final List<String> variants;
}
