/// How a calaverita talks about its subject.
enum Tone {
  playful('Playful'),
  sarcastic('Sarcastic'),
  dramatic('Dramatic');

  Tone(this.label);

  /// The name shown to people.
  final String label;
}
