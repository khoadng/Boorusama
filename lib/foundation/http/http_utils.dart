// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

typedef DataFetcher = Future<HttpResponse<dynamic>> Function();

TaskEither<BooruError, HttpResponse<dynamic>> tryParseResponse({
  required DataFetcher fetcher,
}) =>
    TaskEither.tryCatch(
      () => fetcher(),
      (error, stackTrace) => error is DioException
          ? error.response.toOption().fold(
                () => AppError(type: AppErrorType.cannotReachServer),
                (response) => ServerError(
                  httpStatusCode: response.statusCode,
                ),
              )
          : AppError(type: AppErrorType.loadDataFromServerFailed),
    );

extension DioResponseX<T> on Response<T> {
  bool get isFailure => statusCode.toOption().fold(
        () => true,
        (code) => code >= 400,
      );

  int get statusCodeOrZero => statusCode != null ? statusCode! : 0;
}
