// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

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
    logger.logI('Network',
        'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final response = err.response;
    logger.logI('Network',
        'Completed ${response?.requestOptions.method} to ${response?.requestOptions.uri} with status: ${response?.statusCodeOrZero} and body ${response?.data}');
    super.onError(err, handler);
  }
}
