// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../errors/types.dart';

typedef DataFetcher<T> = Future<T> Function();

bool _isHandshakeException(Object? error) {
  final errorStr = error.toString().toLowerCase();
  return errorStr.contains('handshake') ||
      errorStr.contains('tlsv1_alert_no_application_protocol');
}

TaskEither<BooruError, T> tryFetchRemoteData<T>({
  required DataFetcher<T> fetcher,
}) => TaskEither.tryCatch(
  () => fetcher(),
  (error, stackTrace) => switch (error) {
    DioException(:final response?) => ServerError(
      httpStatusCode: response.statusCode,
      message: response.data,
    ),
    DioException(:final error?) when _isHandshakeException(error) => AppError(
      type: AppErrorType.handshakeFailed,
      message: error.toString(),
    ),
    DioException() => AppError(
      type: AppErrorType.cannotReachServer,
      message: error.toString(),
    ),
    _ => AppError(
      type: AppErrorType.loadDataFromServerFailed,
      message: error.toString(),
    ),
  },
);

abstract interface class AppHttpHeaders {
  static const cookieHeader = 'cookie';
  static const contentLengthHeader = 'content-length';
  static const userAgentHeader = 'user-agent';
}

const _kImageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.avif',
  '.svg',
};

bool defaultImageRequestChecker(Uri uri) {
  final ext = urlExtension(uri.toString());

  return _kImageExtensions.contains(ext);
}

class HttpUtils {
  static bool isImageRequest(RequestOptions options) {
    return defaultImageRequestChecker(options.uri);
  }
}

extension DioResponseX<T> on Response<T> {
  int get statusCodeOrZero => statusCode != null ? statusCode! : 0;
}
