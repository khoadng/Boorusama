// Package imports:
import 'package:dio/dio.dart';

class DanbooruRateLimitConfig {
  const DanbooruRateLimitConfig({
    this.requestsPerSecond = 10,
    this.windowSizeMs = 1000,
    this.maxDelayMs = 5000, // Safety limit to prevent excessive waits
  });

  final int requestsPerSecond;
  final int windowSizeMs;
  final int maxDelayMs;
}

class DanbooruRateLimitInterceptor extends Interceptor {
  DanbooruRateLimitInterceptor({
    DanbooruRateLimitConfig? config,
  }) : _config = config ?? const DanbooruRateLimitConfig();

  final DanbooruRateLimitConfig _config;
  final List<DateTime> _requestTimestamps = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only apply rate limiting to GET requests (read requests)
    if (options.method.toUpperCase() != 'GET') {
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
    if (_requestTimestamps.length >= _config.requestsPerSecond) {
      final oldestInWindow = _requestTimestamps.first;
      final timeSinceOldest = now.difference(oldestInWindow).inMilliseconds;
      final delayNeeded = _config.windowSizeMs - timeSinceOldest;

      if (delayNeeded > 0) {
        final delayMs = delayNeeded.clamp(0, _config.maxDelayMs);
        await Future.delayed(Duration(milliseconds: delayMs));

        // Update now after delay and clean timestamps again
        final delayedNow = DateTime.now();
        _requestTimestamps.removeWhere(
          (timestamp) =>
              delayedNow.difference(timestamp).inMilliseconds >=
              _config.windowSizeMs,
        );

        // Add the actual request timestamp
        _requestTimestamps.add(delayedNow);
      } else {
        _requestTimestamps.add(now);
      }
    } else {
      _requestTimestamps.add(now);
    }

    handler.next(options);
  }
}
