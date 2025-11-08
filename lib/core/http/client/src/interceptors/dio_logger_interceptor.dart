// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../types/dio_ext.dart';

const _kImageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.avif',
};

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this.logger,
  });

  final Logger logger;
  final requestTimeLogs = <String, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldIgnoreRequest(options)) {
      super.onRequest(options, handler);
      return;
    }

    logger.info('Network', 'Sending ${options.method} to ${options.uri}');
    requestTimeLogs[options.uri.toString()] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldIgnoreRequest(response.requestOptions)) {
      super.onResponse(response, handler);
      return;
    }

    final duration = getRequestDuration(response.requestOptions);
    final durationText = _parseRequestDuration(duration);
    final serverRuntime = response.headers.value('x-runtime');
    final serverRuntimeText = _parseServerRuntime(serverRuntime);

    logger.info(
      'Network',
      'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}$durationText$serverRuntimeText',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (_shouldIgnoreRequest(response?.requestOptions)) {
      super.onError(err, handler);
      return;
    }

    final duration = getRequestDuration(response?.requestOptions);
    final durationText = _parseRequestDuration(duration);

    if (response != null) {
      logger.info(
        'Network',
        'Completed ${response.requestOptions.method} to ${response.requestOptions.uri} with status: ${response.statusCodeOrZero}, body ${response.data}$durationText',
      );
    } else {
      logger.error('Network', 'Completed with error: ${err.message}');
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

bool _shouldIgnoreRequest(RequestOptions? options) {
  final uri = options?.uri;

  if (uri == null) return true;

  final ext = urlExtension(uri.toString());
  if (_kImageExtensions.contains(ext)) {
    return true;
  }

  // ignore favicon requests
  if (uri.toString().contains('www.google.com/s2/favicons')) {
    return true;
  }

  return false;
}
