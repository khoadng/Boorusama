// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/common/string_utils.dart';

void main() {
  test('get first character should return correct value', () {
    const str = 'foo';
    expect(str.getFirstCharacter(), 'f');
  });

  test('get last character should return correct value', () {
    const str = 'bar';
    expect(str.getLastCharacter(), 'r');
  });

  test('get first character should return empty if string is empty', () {
    const str = '';
    expect(str.getFirstCharacter(), '');
  });

  test('get last character should return empty if string is empty', () {
    const str = '';
    expect(str.getLastCharacter(), '');
  });

  test('replace with condition should work', () {
    const str = 'bar';
    expect(
      str.replaceAtIndexWhen(
          condition: (value) => value.getLastCharacter() == 'r',
          indexSelector: (value) => value.length - 1,
          newChar: 'T'),
      'baT',
    );
  });
}
