// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../../ddos/handler/types.dart';
import '../../../../ddos/solver/types.dart';

class DioProtectionInterceptor extends Interceptor {
  DioProtectionInterceptor({
    required HttpProtectionHandler protectionHandler,
    required Dio dio,
  }) : _protectionHandler = protectionHandler,
       _dio = dio;

  static const _attemptKey = 'boorusama.protection_attempt';

  ProtectionAttempt _attempt(RequestOptions options) =>
      options.extra.putIfAbsent(
            _attemptKey,
            () => _protectionHandler.beginAttempt(
              options.uri,
              ProtectionSource.dio,
            ),
          )
          as ProtectionAttempt;

  static const _protectionRetryKey = 'boorusama.ddos_protection_retry';

  final HttpProtectionHandler _protectionHandler;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final attempt = _attempt(options);
    attempt.record(
      RequestSent(
        method: options.method,
        retry: _isProtectionRetry(options),
        backend: _dio.httpClientAdapter.runtimeType.toString(),
      ),
      sensitive: ProtectionRequestDetails(options.uri),
    );
    try {
      final headers = await _protectionHandler.prepareRequestHeaders(
        options.uri,
        options.headers.map((k, v) => MapEntry(k, v.toString())),
        attempt: _attempt(options),
      );

      options.headers.addAll(headers);
    } catch (e) {
      attempt.record(
        ProtectionOperationFailed(
          ProtectionOperation.prepareHeaders,
          e.runtimeType.toString(),
        ),
      );
      // Continue with request even if header preparation fails
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final attempt = _attempt(response.requestOptions);
    attempt.record(
      ResponseReceived(
        status: response.statusCode,
        retry: _isProtectionRetry(response.requestOptions),
      ),
    );
    if (_isProtectionRetry(response.requestOptions)) {
      return super.onResponse(response, handler);
    }

    try {
      final isProtection = await _protectionHandler.handleResponse(
        DioResponseAdapter(response),
        attempt: attempt,
      );

      if (isProtection) {
        final retryResponse = await _retryAfterProtection(
          response.requestOptions,
        );
        _protectionHandler.resetRetryAttempts(response.requestOptions.uri);
        handler.next(retryResponse);
        return;
      }
    } catch (e) {
      attempt.record(
        ProtectionOperationFailed(
          ProtectionOperation.recoveryOrRetry,
          e.runtimeType.toString(),
        ),
      );
      // Continue with normal response if handling fails
    }

    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = _attempt(err.requestOptions);
    attempt.record(
      ResponseReceived(
        status: err.response?.statusCode,
        errorType: err.type.name,
        retry: _isProtectionRetry(err.requestOptions),
      ),
    );
    if (_isProtectionRetry(err.requestOptions)) {
      return handler.next(err);
    }

    try {
      final solved = await _protectionHandler.handleError(
        DioErrorAdapter(err),
        attempt: attempt,
      );

      if (solved) {
        final response = await _retryAfterProtection(err.requestOptions);
        _protectionHandler.resetRetryAttempts(err.requestOptions.uri);
        handler.resolve(response);
        return;
      }
    } catch (e) {
      attempt.record(
        ProtectionOperationFailed(
          ProtectionOperation.recoveryOrRetry,
          e.runtimeType.toString(),
        ),
      );
      // If handling fails, continue with the error
    }

    return handler.next(err);
  }

  bool _isProtectionRetry(RequestOptions options) =>
      options.extra[_protectionRetryKey] == true;

  Future<Response<dynamic>> _retryAfterProtection(
    RequestOptions options,
  ) async {
    final attempt = _attempt(options);
    attempt.retries++;
    attempt.record(RetryDispatched(attempt.retries));
    final previous = options.extra[_protectionRetryKey];
    options.extra[_protectionRetryKey] = true;

    try {
      final headers = await _protectionHandler.prepareRequestHeaders(
        options.uri,
        options.headers.map((k, v) => MapEntry(k, v.toString())),
        attempt: _attempt(options),
      );

      options.headers
        ..clear()
        ..addAll(headers);

      return await _dio.fetch(options);
    } finally {
      if (previous == null) {
        options.extra.remove(_protectionRetryKey);
      } else {
        options.extra[_protectionRetryKey] = previous;
      }
    }
  }
}

class DioResponseAdapter implements HttpResponse {
  const DioResponseAdapter(this._response);

  final Response _response;

  @override
  int? get statusCode => _response.statusCode;
  @override
  dynamic get data => _decodeData(_response.data);
  @override
  Uri get requestUri => _response.requestOptions.uri;
  @override
  Map<String, dynamic> get headers => _response.headers.map;
}

class DioErrorAdapter implements HttpError {
  const DioErrorAdapter(this._error);
  final DioException _error;

  @override
  HttpResponse? get response =>
      _error.response != null ? DioResponseAdapter(_error.response!) : null;
  @override
  Uri get requestUri => _error.requestOptions.uri;
  @override
  String? get message => _error.message;
}

dynamic _decodeData(dynamic data) => switch (data) {
  final List<int> bytes => _tryDecodeBytes(bytes),
  _ => data,
};

dynamic _tryDecodeBytes(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {
    return bytes;
  }
}
