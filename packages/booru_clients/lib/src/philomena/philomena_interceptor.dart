// Package imports:
import 'package:dio/dio.dart';

import 'types/constants.dart';

class PhilomenaRateLimitConfig {
  const PhilomenaRateLimitConfig({
    this.normalRequestsLimit = 30,
    this.normalRequestsWindowSeconds = 5,
    this.searchRequestsLimit = 20,
    this.searchRequestsWindowSeconds = 10,
    this.challengeBackoffSeconds = 5,
    this.blockBackoffSeconds = 900, // 15 minutes in seconds
  });

  final int normalRequestsLimit;
  final int normalRequestsWindowSeconds;
  final int searchRequestsLimit;
  final int searchRequestsWindowSeconds;
  final int challengeBackoffSeconds;
  final int blockBackoffSeconds;
}

class PhilomenaRateLimitInterceptor extends Interceptor {
  PhilomenaRateLimitInterceptor({
    PhilomenaRateLimitConfig? config,
  }) : _config = config ?? const PhilomenaRateLimitConfig();

  final PhilomenaRateLimitConfig _config;
  final List<DateTime> _normalRequests = [];
  final List<DateTime> _searchRequests = [];
  DateTime? _backoffUntil;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check backoff
    if (_backoffUntil?.isAfter(DateTime.now()) == true) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Backing off until $_backoffUntil',
        ),
      );
      return;
    }

    final now = DateTime.now();
    final isSearch = options.path.startsWith(kAPISearchPath);

    if (isSearch) {
      // Clean old search requests
      _searchRequests.removeWhere(
        (time) =>
            now.difference(time).inSeconds >=
            _config.searchRequestsWindowSeconds,
      );

      if (_searchRequests.length >= _config.searchRequestsLimit) {
        handler.reject(
          DioException(
            requestOptions: options,
            error:
                'Search rate limit exceeded (${_config.searchRequestsLimit}/${_config.searchRequestsWindowSeconds}s)',
          ),
        );
        return;
      }
      _searchRequests.add(now);
    } else {
      // Clean old normal requests
      _normalRequests.removeWhere(
        (time) =>
            now.difference(time).inSeconds >=
            _config.normalRequestsWindowSeconds,
      );

      if (_normalRequests.length >= _config.normalRequestsLimit) {
        handler.reject(
          DioException(
            requestOptions: options,
            error:
                'Rate limit exceeded (${_config.normalRequestsLimit}/${_config.normalRequestsWindowSeconds}s)',
          ),
        );
        return;
      }
      _normalRequests.add(now);
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 501:
        // Challenge - back off
        _backoffUntil = DateTime.now().add(
          Duration(seconds: _config.challengeBackoffSeconds),
        );
        break;
      case 500:
        // Blocked - back off
        _backoffUntil = DateTime.now().add(
          Duration(seconds: _config.blockBackoffSeconds),
        );
        break;
    }
    handler.next(err);
  }
}
