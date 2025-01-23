// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../downloads/urls.dart';

const _kImageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.avif',
};

bool _defaultImageRequestChecker(Uri uri) {
  final ext = sanitizedExtension(uri.toString());

  return _kImageExtensions.contains(ext);
}

class ImageRequestDeduplicateInterceptor extends Interceptor {
  ImageRequestDeduplicateInterceptor({
    this.isImageRequest = _defaultImageRequestChecker,
  });

  final bool Function(Uri uri) isImageRequest;

  final _pendingRequests = <String, Completer<Response>>{};

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
      // A request is already in-flight, we will complete this request by attaching to the existing future
      final existingCompleter = _pendingRequests[key]!;

      // When the existingCompleter completes, we just fulfill the new request with the same response
      existingCompleter.future.then(
        (response) {
          handler.resolve(response);
        },
        onError: (err) {
          handler.reject(err);
        },
      );
    } else {
      // No existing request, so create a new Completer for this key
      final completer = Completer<Response>();
      _pendingRequests[key] = completer;

      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _deduplicateKey(response.requestOptions);

    // If we have a completer for this response, complete it
    final completer = _pendingRequests[key];
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
      _pendingRequests.remove(key);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _deduplicateKey(err.requestOptions);

    // Complete the future with an error if still pending
    final completer = _pendingRequests[key];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(err);
      _pendingRequests.remove(key);
    }

    handler.next(err);
  }
}
