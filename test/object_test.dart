// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/dart.dart';

void main() {
  group('toDoubleOrNull', () {
    test('should return double value when object is a num', () {
      const numValue = 10;
      expect(numValue.toDoubleOrNull(), equals(10.0));
    });

    test('should return double value when object is a double', () {
      const doubleValue = 3.14;
      expect(doubleValue.toDoubleOrNull(), equals(3.14));
    });

    test(
        'should return double value when object is a string representation of a number',
        () {
      const stringValue = '5.5';
      expect(stringValue.toDoubleOrNull(), equals(5.5));
    });

    test(
        'should return null when object is not a num or string representation of a number',
        () {
      const nonNumericValue = true;
      expect(nonNumericValue.toDoubleOrNull(), isNull);
    });

    test('should return null when object is null', () {
      // ignore: avoid_init_to_null
      const Object? nullValue = null;
      expect(nullValue.toDoubleOrNull(), isNull);
    });
  });
}
