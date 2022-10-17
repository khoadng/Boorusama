// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/domain/error.dart';

void rethrowError(
  Object error, {
  required void Function(int? httpStatusCode) handle,
}) {
  if (error is DioError) {
    if (error.response == null) {
      throw BooruError(
          type: BooruErrorType.client, error: AppError.cannotReachServer);
    } else {
      handle(error.response?.statusCode);
    }
  } else {
    throw BooruError(
      type: BooruErrorType.client,
      error: AppError.failedToParseJSON,
    );
  }
}
