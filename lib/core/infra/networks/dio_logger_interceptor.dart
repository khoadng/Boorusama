// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/infra/loggers.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this.logger,
  });

  final LoggerService logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.logI('Network', 'Sending ${options.method} to ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final int statusCode = response.statusCode ?? -1;
    logger.logI('Network',
        'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: $statusCode');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logger.logE('Network', 'Error: ${err.message}');
    super.onError(err, handler);
  }
}
