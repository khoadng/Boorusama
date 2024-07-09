// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

typedef DataFetcher<T> = Future<T> Function();

TaskEither<BooruError, T> tryFetchRemoteData<T>({
  required DataFetcher<T> fetcher,
}) =>
    TaskEither.tryCatch(
      () => fetcher(),
      (error, stackTrace) => error is DioException
          ? error.response.toOption().fold(
                () => AppError(type: AppErrorType.cannotReachServer),
                (response) => ServerError(
                  httpStatusCode: response.statusCode,
                  message: response.data,
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

abstract interface class AppHttpHeaders {
  static const cookieHeader = "cookie";
  static const contentLengthHeader = "content-length";
  static const userAgentHeader = "user-agent";
}
