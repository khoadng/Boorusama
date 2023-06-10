// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/functional.dart';

void main() {
  test('tryDecodeJson returns Right with valid input', () {
    const jsonString = '{"name": "Alice", "age": 30}';
    final result = tryDecodeJson(jsonString);
    expect(result.isRight(), isTrue);
  });

  test('tryDecodeJson returns Left with invalid JSON format', () {
    const jsonString = '{name: "Alice", age: 30}';
    final result = tryDecodeJson(jsonString);
    expect(result, equals(left(JsonDecodeError.invalidJsonFormat)));
  });
}
