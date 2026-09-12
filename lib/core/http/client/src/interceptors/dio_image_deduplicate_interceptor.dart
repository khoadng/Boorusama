// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../types/http_utils.dart';

class ImageRequestDeduplicateInterceptor extends Interceptor {
  ImageRequestDeduplicateInterceptor({
    this.isImageRequest = defaultImageRequestChecker,
  });

  final bool Function(Uri uri) isImageRequest;

  final _pendingRequests = <String, List<RequestInterceptorHandler>>{};

  String _deduplicateKey(RequestOptions options) {
    return options.uri.toString();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    // Make sure this is an image request
    if (!isImageRequest(options.uri)) {
      return handler.next(options);
    }

    final key = _deduplicateKey(options);

    // Check if there's already a pending request with the same key
    if (_pendingRequests.containsKey(key)) {
      _pendingRequests[key]!.add(handler);
    } else {
      _pendingRequests[key] = [];

      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _deduplicateKey(response.requestOptions);

    for (final waiting in _pendingRequests.remove(key) ?? const []) {
      waiting.resolve(response);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _deduplicateKey(err.requestOptions);

    for (final waiting in _pendingRequests.remove(key) ?? const []) {
      waiting.reject(err);
    }

    handler.next(err);
  }
}
