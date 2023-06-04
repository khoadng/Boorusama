// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/error.dart';

void rethrowError(Object error) {
  if (error is DioError) {
    if (error.response == null) {
      throw AppError(type: AppErrorType.cannotReachServer);
    } else {
      throw ServerError(
        httpStatusCode: error.response?.statusCode,
      );
    }
  } else {
    throw AppError(type: AppErrorType.failedToParseJSON);
  }
}

void handleError(Object e) {
  rethrowError(e);
}
