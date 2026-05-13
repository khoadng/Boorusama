// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/text_markup/types.dart';

void main() {
  group('text emoji shortcodes', () {
    test('extracts normalized shortcode names', () {
      expect(
        extractTextEmojiShortcodes(':Smile: :party_hat: :123: :http: :ab:'),
        {'smile', 'party_hat'},
      );
    });
  });
}
