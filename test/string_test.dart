// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/dart.dart';

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
}
