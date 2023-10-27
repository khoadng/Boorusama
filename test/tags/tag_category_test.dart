// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

void main() {
  group('[tag category test]', () {
    test('general', () => expect(intToTagCategory(0), TagCategory.general));
    test('artist', () => expect(intToTagCategory(1), TagCategory.artist));
    test('copyright', () => expect(intToTagCategory(3), TagCategory.copyright));
    test('character', () => expect(intToTagCategory(4), TagCategory.character));
    test('meta', () => expect(intToTagCategory(5), TagCategory.meta));
    test(
      '-1 => general',
      () => expect(intToTagCategory(-1), TagCategory.general),
    );
    test(
      '100 => general',
      () => expect(intToTagCategory(100), TagCategory.general),
    );
  });
}
