import 'package:calaverita_domain/calaverita_domain.dart';

/// Four-line verses with `{name}` and `{job}` slots, per [Tone].
///
/// The rhymes sit on fixed words, so they hold for any name and job.
class CalaveritaTemplates {
  const CalaveritaTemplates();

  /// The verses written in [tone].
  List<List<String>> of(Tone tone) => switch (tone) {
    Tone.playful => _playful,
    Tone.sarcastic => _sarcastic,
    Tone.dramatic => _dramatic,
  };

  static const _playful = [
    [
      "Doña Calavera knocked on {name}'s door,",
      '"Leave your {job} desk, there are tamales and more!"',
      'But {name} said, "One more email, por favor,"',
      'And that is why the skull still waits at the door.',
    ],
    [
      '{name} the {job}, so charming, so sweet,',
      'Danced with a skeleton, two left feet.',
      'The mariachis played and the skulls all cheered,',
      '"Best {job} ever!" ... and then disappeared.',
    ],
    [
      'Little skull {name}, with sugar so bright,',
      'Left the {job} life for a fiesta tonight.',
      'With cempasúchil crowns and a conga line, too,',
      'Even Death asked, "Hey {name}, can I come with you?"',
    ],
  ];

  static const _sarcastic = [
    [
      '{name}, the {job}, so busy, so wise,',
      'Met Death in a meeting and rolled both eyes.',
      '"Could this have been an email?" {name} replied,',
      '"Too late," said La Muerte, "enjoy the ride."',
    ],
    [
      'They say a {job} never truly rests,',
      'Yet {name} is napping, put that to the test.',
      'La Catrina brings flowers, and says with a grin,',
      '"Finally on time, now let the party begin."',
    ],
    [
      'Here lies {name}, the pride of the {job} crew,',
      'Who always knew best, and told us too.',
      'The skeleton asked, "Any last words, my friend?"',
      '"Actually," said {name}... and that was not the end.',
    ],
  ];

  static const _dramatic = [
    [
      'Oh {name}, great {job} of tragic renown,',
      'The marigolds weep as the sun goes down.',
      'Yet fear not, dear soul, for the music will play,',
      'And your {job} legend will dance on the day.',
    ],
    [
      'Beneath the moon, so pale and so wide,',
      '{name} the {job} walks with Death side by side.',
      'They share pan de muerto, they laugh, they sing,',
      'And the underworld crowns them the {job} king.',
    ],
    [
      'A candle for {name}, a flame in the night,',
      'The {job} who worked with all of their might.',
      'Now skulls made of sugar bring tears and delight,',
      'And {name} gets the last word, as is only right.',
    ],
  ];
}
