// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/dart.dart';

void main() {
  test('Replace a element at index in an immutable list', () {
    final items = [1, 2, 3, 4, 5];

    final expected = [1, 2, 100, 4, 5];

    final actual = items.replaceAt(2, 100);

    for (var i = 0; i < items.length; i++) {
      expect(actual[i], expected[i]);
    }

    expect(identical(actual, items), isFalse);
  });

  test('Replace a element with condition in an immutable list', () {
    final items = [1, 2, 3, 4, 5];

    final expected = [1, 2, 100, 4, 5];

    final actual = items.replaceFirst(100, (e) => e == 3);

    for (var i = 0; i < items.length; i++) {
      expect(actual[i], expected[i]);
    }

    expect(identical(actual, items), isFalse);
  });
}
