// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/dart.dart';

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
}
