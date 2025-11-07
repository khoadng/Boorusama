// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/favgroups/favgroups/src/types/update_order.dart';

void main() {
  group('updateOrder', () {
    test(
      'should reorder items while maintaining original positions of unchanged items - case 1',
      () {
        final allIds = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        final oldIds = {1, 2, 3, 4};
        final newIds = {1, 3, 4, 2};

        final result = updateOrder(allIds, oldIds, newIds);

        expect(result, [1, 3, 4, 2, 5, 6, 7, 8, 9]);
      },
    );

    test(
      'should reorder middle section while preserving outer items - case 2',
      () {
        final allIds = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        final oldIds = {4, 5, 6, 7};
        final newIds = {7, 5, 6, 4};

        final result = updateOrder(allIds, oldIds, newIds);

        expect(result, [1, 2, 3, 7, 5, 6, 4, 8, 9]);
      },
    );

    test(
      'should handle deleted items and preserve remaining order - case 3',
      () {
        final allIds = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        final oldIds = {1, 2, 3, 4, 5};
        final newIds = {3, 2};

        final result = updateOrder(allIds, oldIds, newIds);

        expect(result, [3, 2, 6, 7, 8, 9]);
      },
    );

    test('should throw if oldIds and allIds not have a same sequence', () {
      final allIds = {1111, 2222, 3333, 4444, 5555, 6666, 7777, 8888, 9999};
      final oldIds = {1111, 2222, 3333, 6666, 7777, 8888, 9999};
      final newIds = {2222, 1111, 3333, 6666, 7777, 8888, 9999};

      expect(
        () => updateOrder(allIds, oldIds, newIds),
        throwsArgumentError,
      );
    });

    test('should handle empty inputs', () {
      expect(updateOrder({}, {}, {}), []);
      expect(updateOrder({1, 2, 3}, {}, {}), [1, 2, 3]);
    });

    test('should handle invalid IDs', () {
      final allIds = {1, 2, 3};
      final oldIds = {1, 4}; // 4 is invalid
      final newIds = {1, 2};

      expect(updateOrder(allIds, oldIds, newIds), [1, 2, 3]);
    });

    test('should handle when all items are deleted', () {
      final allIds = {1, 2, 3};
      final oldIds = {1, 2, 3};
      final newIds = <int>{};

      expect(updateOrder(allIds, oldIds, newIds), []);
    });

    test('should handle when newIds contains items not in oldIds', () {
      final allIds = {1, 2, 3, 4, 5};
      final oldIds = {1, 2, 3};
      final newIds = {1, 4, 2}; // 4 wasn't in oldIds

      final result = updateOrder(allIds, oldIds, newIds);

      expect(result, [1, 2, 4, 5]);
    });

    test('should handle when oldIds is larger than allIds', () {
      final allIds = {1, 2};
      final oldIds = {1, 2, 3, 4};
      final newIds = {2, 1};

      final result = updateOrder(allIds, oldIds, newIds);

      expect(result, [1, 2]);
    });
  });
}
