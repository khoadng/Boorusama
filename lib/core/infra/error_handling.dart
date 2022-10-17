// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/domain/error.dart';

void rethrowError(Object error) {
  if (error is DioError) {
    if (error.response == null) {
      throw BooruError(error: AppError(type: AppErrorType.cannotReachServer));
    } else {
      throw BooruError(
          error: ServerError(httpStatusCode: error.response?.statusCode));
    }
  } else {
    throw BooruError(error: AppError(type: AppErrorType.failedToParseJSON));
  }
}
