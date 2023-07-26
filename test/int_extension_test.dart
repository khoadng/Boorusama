// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/utils/int_utils.dart';

void main() {
  testDigitCount();
}

void testDigitCount() {
  test('Test digitCount() for positive integers', () {
    expect(0.digitCount(), equals(1));
    expect(1.digitCount(), equals(1));
    expect(9.digitCount(), equals(1));
    expect(10.digitCount(), equals(2));
    expect(99.digitCount(), equals(2));
    expect(100.digitCount(), equals(3));
    expect(12345.digitCount(), equals(5));
    expect(987654321.digitCount(), equals(9));
    expect(1000000000.digitCount(), equals(10));
    expect(10000000000.digitCount(), equals(11));
    expect(1234567890123456789.digitCount(), equals(19));
  });

  test('Test digitCount() for negative integers', () {
    expect((-1).digitCount(), equals(1));
    expect((-9).digitCount(), equals(1));
    expect((-10).digitCount(), equals(2));
    expect((-99).digitCount(), equals(2));
    expect((-100).digitCount(), equals(3));
    expect((-12345).digitCount(), equals(5));
    expect((-987654321).digitCount(), equals(9));
  });
}
