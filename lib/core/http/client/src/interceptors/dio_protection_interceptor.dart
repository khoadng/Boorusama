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

  final HttpProtectionHandler _protectionHandler;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final headers = await _protectionHandler.prepareRequestHeaders(
        options.uri,
        options.headers.map((k, v) => MapEntry(k, v.toString())),
      );

      options.headers.addAll(headers);
    } catch (e) {
      // Continue with request even if header preparation fails
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      final isProtection = await _protectionHandler.handleResponse(
        DioResponseAdapter(response),
      );

      if (isProtection) {
        final retryResponse = await _dio.fetch(response.requestOptions);
        handler.next(retryResponse);
        return;
      }
    } catch (e) {
      // Continue with normal response if handling fails
    }

    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final solved = await _protectionHandler.handleError(DioErrorAdapter(err));

      if (solved) {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      }
    } catch (e) {
      // If handling fails, continue with the error
    }

    return handler.next(err);
  }
}

class DioResponseAdapter implements HttpResponse {
  const DioResponseAdapter(this._response);

  final Response _response;

  @override
  int? get statusCode => _response.statusCode;
  @override
  dynamic get data => _response.data;
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
