// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:fpdart/fpdart.dart';

enum JsonDecodeError {
  invalidJsonFormat,
  unknown,
}

Either<JsonDecodeError, T> tryDecodeJson<T>(String? jsonString) {
  try {
    if (jsonString == null) {
      return left(JsonDecodeError.invalidJsonFormat);
    }

    final json = jsonDecode(jsonString);
    return right(json);
  } on FormatException {
    return left(JsonDecodeError.invalidJsonFormat);
  } catch (_) {
    return left(JsonDecodeError.unknown);
  }
}
