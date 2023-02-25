// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/common/collection_utils.dart';

void main() {
  group('[getOrNull]', () {
    test('getOrNull returns element', () {
      final list = <int>[1];
      expect(list.getOrNull(0), 1);
    });

    test('getOrNull returns null', () {
      final list = <int>[];
      expect(list.getOrNull(0), null);
    });

    test('getOrNull returns null for out of range index', () {
      final list = <int>[1];
      expect(list.getOrNull(1), null);
    });
    test('getOrNull returns null for negative index', () {
      final list = <int>[1];
      expect(list.getOrNull(-1), null);
    });
  });

  group('[firstOrNull]', () {
    test('firstOrNull returns first element that matches selector', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.firstOrNull((e) => e.isEven), 2);
    });

    test('firstOrNull returns null for empty list', () {
      final list = <int>[];
      expect(list.firstOrNull((e) => e.isEven), null);
    });

    test('firstOrNull returns null for no matching elements', () {
      final list = [1, 3, 5];
      expect(list.firstOrNull((e) => e.isEven), null);
    });
  });
}
