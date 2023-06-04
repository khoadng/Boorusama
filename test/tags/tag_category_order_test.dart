// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';

void main() {
  group('[tag category order test]', () {
    test('artist', () => expect(tagCategoryToOrder(TagCategory.artist), 0));
    test(
      'copyright',
      () => expect(tagCategoryToOrder(TagCategory.copyright), 1),
    );
    test(
      'character',
      () => expect(tagCategoryToOrder(TagCategory.charater), 2),
    );
    test('general', () => expect(tagCategoryToOrder(TagCategory.general), 3));
    test('meta', () => expect(tagCategoryToOrder(TagCategory.meta), 4));
    test('_invalid', () => expect(tagCategoryToOrder(TagCategory.invalid_), 5));
  });
}
