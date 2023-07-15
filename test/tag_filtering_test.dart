// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

void main() {
  group('single', () {
    group('no operator', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'd'),
          false,
        );
      });
    });

    group('NOT', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '-d'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '-a'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '~a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '~d'),
          false,
        );
      });
    });

    group('Metatags', () {
      group('Rating', () {
        group('General', () {
          test('positive', () {
            expect(
              checkIfTagsContainsTagExpression(
                TagFilterData(
                    tags: ['a', 'b', 'c'], rating: Rating.general, score: 0),
                'rating:general',
              ),
              true,
            );
          });

          test('negative', () {
            expect(
              checkIfTagsContainsTagExpression(
                TagFilterData(
                    tags: ['a', 'b', 'c'], rating: Rating.general, score: 0),
                'rating:explicit',
              ),
              false,
            );
          });
        });
      });

      group('Score', () {
        test('positive', () {
          expect(
            checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.general, score: -10),
              'score:<-4',
            ),
            true,
          );
        });

        test('negative', () {
          expect(
            checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.general, score: 0),
              'score:<-4',
            ),
            false,
          );
        });
      });
    });
  });

  group('multiple', () {
    group('AND', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a d'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '~a ~b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), '~d ~e'),
          false,
        );
      });
    });

    // NOT group
    group('NOT', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'q', 'w'].toTagFilterData(), 'a b -c -d'),
          true,
        );
      });

      test('negative 1', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c', 'd'].toTagFilterData(), 'a b -c -d'),
          false,
        );
      });

      test('negative 2', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a b -c -d'),
          false,
        );
      });

      test('negative 3', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'd'].toTagFilterData(), 'a b -c -d'),
          false,
        );
      });

      test('negative 4', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['q', 'w', 'e', 'r'].toTagFilterData(), 'a b -c -d'),
          false,
        );
      });
    });

    group('AND + OR', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a ~b ~d'),
          true,
        );
      });

      test('positive 2 ', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'd'].toTagFilterData(), 'a ~b ~d'),
          true,
        );
      });

      test('negative 1 (AND exists, OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'a ~d ~e'),
          false,
        );
      });

      test('negative 2 (AND not exists, OR exists)', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'd ~a ~b'),
          false,
        );
      });

      test('negative 3 (AND and OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(
              ['a', 'b', 'c'].toTagFilterData(), 'd ~e'),
          false,
        );
      });
    });

    group('AND + Metatags', () {
      test('positive 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: 0),
              'a rating:explicit'),
          true,
        );
      });

      test('positive 2 (score)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: -10),
              'a score:<-5'),
          true,
        );
      });

      test('negative 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: 0),
              'a rating:general'),
          false,
        );
      });

      test('negative 2 (score)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: -1),
              'a score:<-5'),
          false,
        );
      });
    });

    group('NOT + Metatags', () {
      test('positive 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: 0),
              'a -rating:general'),
          true,
        );
      });

      test('positive 2 (score + rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.general, score: -10),
              'a score:<-5 -rating:explicit'),
          true,
        );
      });

      test('negative 1 (rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.general, score: 0),
              'a -rating:general'),
          false,
        );
      });

      test('negative 2 (score + rating)', () {
        expect(
          checkIfTagsContainsTagExpression(
              TagFilterData(
                  tags: ['a', 'b', 'c'], rating: Rating.explicit, score: -100),
              'a score:<-5 -rating:explicit'),
          false,
        );
      });
    });
  });
}
