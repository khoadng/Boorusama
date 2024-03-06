// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';

void main() {
  group('[post rating test]', () {
    test(
      'general',
      () => expect(mapStringToRating('g'), equals(Rating.general)),
    );
    test(
      'sensitive',
      () => expect(mapStringToRating('s'), equals(Rating.sensitive)),
    );
    test(
      'questionable',
      () => expect(mapStringToRating('q'), equals(Rating.questionable)),
    );
    test(
      'explicit',
      () => expect(mapStringToRating('e'), equals(Rating.explicit)),
    );
    test(
      'anything',
      () => expect(mapStringToRating('anything'), equals(Rating.unknown)),
    );
  });
}
