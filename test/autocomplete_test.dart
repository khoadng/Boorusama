// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/search/queries/autocomplete_utils.dart';

void main() {
  group('replaceOrAppendTag', () {
    test('should replace incomplete tag when there is a partial match', () {
      expect(replaceOrAppendTag('ca', 'cat'), 'cat ');
      expect(replaceOrAppendTag('cat dog anim', 'animal'), 'cat dog animal ');
      expect(replaceOrAppendTag('red', 'red_hair'), 'red_hair ');
      expect(replaceOrAppendTag('cat ong', 'long_hair'), 'cat long_hair ');
    });

    test('should append tag when no partial match exists', () {
      expect(replaceOrAppendTag('cat', 'dog'), 'cat dog ');
      expect(replaceOrAppendTag('cat dog', 'bird'), 'cat dog bird ');
    });
  });
}
