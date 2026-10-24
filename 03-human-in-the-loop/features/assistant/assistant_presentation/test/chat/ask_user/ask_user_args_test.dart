import 'package:assistant_presentation/chat/ask_user/ask_user_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AskUserArgs, () {
    test('reads the question and the options', () {
      final args = AskUserArgs.fromJson(const {
        'question': 'How should I roast Mario?',
        'options': [
          {'id': 'playful', 'label': 'Playful', 'hint': 'Friendly teasing'},
          {'id': 'sarcastic', 'label': 'Sarcastic'},
        ],
      });

      expect(args.question, 'How should I roast Mario?');
      expect(args.options, const [
        AskUserOption(
          id: 'playful',
          label: 'Playful',
          hint: 'Friendly teasing',
        ),
        AskUserOption(id: 'sarcastic', label: 'Sarcastic'),
      ]);
    });

    test('skips options without an id or a label', () {
      final args = AskUserArgs.fromJson(const {
        'options': [
          {'id': 'a', 'label': 'A'},
          {'id': '', 'label': 'No id'},
          {'id': 'c'},
          'not an option',
          {'id': 'd', 'label': 'D', 'hint': ''},
        ],
      });

      expect(args.options, const [
        AskUserOption(id: 'a', label: 'A'),
        AskUserOption(id: 'd', label: 'D'),
      ]);
    });

    test('is empty while nothing has arrived', () {
      final args = AskUserArgs.fromJson(const {});

      expect(args.question, isEmpty);
      expect(args.options, isEmpty);
    });
  });
}
