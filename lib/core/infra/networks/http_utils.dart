// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/functional.dart';

typedef DataFetcher = Future<HttpResponse<dynamic>> Function();

TaskEither<BooruError, HttpResponse<dynamic>> tryParseResponse({
  required DataFetcher fetcher,
}) =>
    TaskEither.tryCatch(
      () => fetcher(),
      (error, stackTrace) => error is DioError
          ? error.response.toOption().fold(
                () => AppError(type: AppErrorType.cannotReachServer),
                (response) => ServerError(
                  httpStatusCode: response.statusCode,
                ),
              )
          : AppError(type: AppErrorType.loadDataFromServerFailed),
    );
