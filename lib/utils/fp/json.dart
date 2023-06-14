// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:boorusama/functional.dart';

enum JsonDecodeError {
  invalidJsonFormat,
  unknown,
}

Either<JsonDecodeError, T> tryDecodeJson<T>(String jsonString) {
  try {
    final json = jsonDecode(jsonString);
    return right(json);
  } on FormatException {
    return left(JsonDecodeError.invalidJsonFormat);
  } catch (_) {
    return left(JsonDecodeError.unknown);
  }
}
