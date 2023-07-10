// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

void main() {
  group('single', () {
    group('no operator', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'd'),
          false,
        );
      });
    });

    group('NOT', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '-d'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '-a'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '~a'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '~d'),
          false,
        );
      });
    });
  });

  group('multiple', () {
    group('AND', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a d'),
          false,
        );
      });
    });

    group('OR', () {
      test('positive', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '~a ~b'),
          true,
        );
      });

      test('negative', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], '~d ~e'),
          false,
        );
      });
    });

    // NOT group
    group('NOT', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'q', 'w'], 'a b -c -d'),
          true,
        );
      });

      test('negative 1', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c', 'd'], 'a b -c -d'),
          false,
        );
      });

      test('negative 2', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a b -c -d'),
          false,
        );
      });

      test('negative 3', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'd'], 'a b -c -d'),
          false,
        );
      });

      test('negative 4', () {
        expect(
          checkIfTagsContainsTagExpression(['q', 'w', 'e', 'r'], 'a b -c -d'),
          false,
        );
      });
    });

    group('AND + OR', () {
      test('positive 1', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a ~b ~d'),
          true,
        );
      });

      test('positive 2 ', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'd'], 'a ~b ~d'),
          true,
        );
      });

      test('negative 1 (AND exists, OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'a ~d ~e'),
          false,
        );
      });

      test('negative 2 (AND not exists, OR exists)', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'd ~a ~b'),
          false,
        );
      });

      test('negative 3 (AND and OR not exists)', () {
        expect(
          checkIfTagsContainsTagExpression(['a', 'b', 'c'], 'd ~e'),
          false,
        );
      });
    });
  });
}
