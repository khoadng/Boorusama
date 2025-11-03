// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../types/http_utils.dart';

/// A resolver function to determine if a request should be rate-limited.
typedef RateLimitResolver = bool Function(RequestOptions options);

bool _defaultRateLimitResolver(RequestOptions options) {
  // Default resolver will not rate limit image requests
  return !HttpUtils.isImageRequest(options);
}

class SlidingWindowRateLimitConfig {
  const SlidingWindowRateLimitConfig({
    required this.requestsPerWindow,
    required this.windowSizeMs,
    this.maxDelayMs = 5000,
    this.resolver = _defaultRateLimitResolver,
  });

  final int requestsPerWindow;
  final int windowSizeMs;
  final int maxDelayMs;
  final RateLimitResolver resolver;
}

class SlidingWindowRateLimitInterceptor extends Interceptor {
  SlidingWindowRateLimitInterceptor({
    required SlidingWindowRateLimitConfig config,
  }) : _config = config;

  final SlidingWindowRateLimitConfig _config;
  final List<DateTime> _requestTimestamps = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if rate limiting should be applied using resolver
    if (!_config.resolver(options)) {
      handler.next(options);
      return;
    }

    final now = DateTime.now();

    // Clean old timestamps outside the window
    _requestTimestamps.removeWhere(
      (timestamp) =>
          now.difference(timestamp).inMilliseconds >= _config.windowSizeMs,
    );

    // Calculate delay needed if we would exceed the limit
    if (_requestTimestamps.length >= _config.requestsPerWindow) {
      final oldestInWindow = _requestTimestamps.first;
      final timeSinceOldest = now.difference(oldestInWindow).inMilliseconds;
      final delayNeeded = _config.windowSizeMs - timeSinceOldest;

      if (delayNeeded > 0) {
        final delayMs = delayNeeded.clamp(0, _config.maxDelayMs);
        await Future.delayed(Duration(milliseconds: delayMs));

        // Update now after delay and clean timestamps again
        final delayedNow = DateTime.now();
        _requestTimestamps
          ..removeWhere(
            (timestamp) =>
                delayedNow.difference(timestamp).inMilliseconds >=
                _config.windowSizeMs,
          )
          // Add the actual request timestamp
          ..add(delayedNow);
      } else {
        _requestTimestamps.add(now);
      }
    } else {
      _requestTimestamps.add(now);
    }

    handler.next(options);
  }
}
