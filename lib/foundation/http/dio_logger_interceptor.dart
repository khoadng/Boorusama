// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/path.dart';

const _kImageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
};

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this.logger,
    required this.booruConfig,
  });

  final LoggerService logger;
  final BooruConfig booruConfig;
  final Map<String, DateTime> requestTimeLogs = <String, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Don't log image requests
    final ext = extension(options.uri.toString());
    if (_kImageExtensions.contains(ext)) {
      super.onRequest(options, handler);
      return;
    }

    logger.logI('Network', 'Sending ${options.method} to ${options.uri}');
    requestTimeLogs[options.uri.toString()] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ext = extension(response.requestOptions.uri.toString());

    if (_kImageExtensions.contains(ext)) {
      super.onResponse(response, handler);
      return;
    }

    final duration = getRequestDuration(response.requestOptions);
    final durationText = _parseRequestDuration(duration);
    final serverRuntime = response.headers.value('x-runtime');
    final serverRuntimeText = _parseServerRuntime(serverRuntime);

    logger.logI('Network',
        'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}$durationText$serverRuntimeText');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    final ext = extension(response?.requestOptions.uri.toString() ?? '');

    if (_kImageExtensions.contains(ext)) {
      super.onError(err, handler);
      return;
    }

    final duration = getRequestDuration(response?.requestOptions);
    final durationText = _parseRequestDuration(duration);

    if (response != null) {
      logger.logI('Network',
          'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}, body ${response.data}$durationText');

      if (response.statusCode == 401) {
        logger.logE('Network',
            'Unauthorized using login: ${booruConfig.login} and api key: ${booruConfig.apiKey}');
      }
    } else {
      logger.logE('Network', 'Completed with error: ${err.message}');
    }
    super.onError(err, handler);
  }

  Duration? getRequestDuration(RequestOptions? requestOptions) {
    if (requestOptions == null) return null;
    final startTime = requestTimeLogs.remove(requestOptions.uri.toString());

    if (startTime == null) return null;

    return DateTime.now().difference(startTime);
  }
}

String _parseServerRuntime(String? value) {
  if (value == null) return '';
  final serverRuntimeSeconds = double.tryParse(value);

  if (serverRuntimeSeconds == null) return '';

  // if less than second, show in milliseconds
  return serverRuntimeSeconds < 1
      ? ' (server runtime: ${(serverRuntimeSeconds * 1000).toStringAsFixed(0)}ms)'
      : ' (server runtime: ${serverRuntimeSeconds.toStringAsFixed(3)}s)';
}

String _parseRequestDuration(Duration? duration) {
  if (duration == null) return '';

  return duration.inSeconds < 1
      ? ' and took ${duration.inMilliseconds}ms'
      : ' and took ${duration.inMilliseconds / 1000}s';
}
