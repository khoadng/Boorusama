// Package imports:
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/http/src/sliding_window_rate_limit_interceptor.dart';

void main() {
  group('SlidingWindowRateLimitInterceptor', () {
    late SlidingWindowRateLimitInterceptor interceptor;
    late MockRequestInterceptorHandler handler;

    setUp(() {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 10,
        windowSizeMs: 1000,
      );
      interceptor = SlidingWindowRateLimitInterceptor(config: config);
      handler = MockRequestInterceptorHandler();
    });

    test('should pass through non-GET requests immediately', () async {
      final options = RequestOptions(path: '/test', method: 'POST');

      final stopwatch = Stopwatch()..start();
      await interceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10));
      expect(handler.nextCalled, isTrue);
    });

    test('should delay GET requests when exceeding rate limit', () async {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 2,
        windowSizeMs: 1000,
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // Fill the window
      await testInterceptor.onRequest(options, handler);
      await testInterceptor.onRequest(options, handler);

      // Third request should be delayed
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(500));
      expect(handler.nextCalled, isTrue);
    });

    test('should clean up old timestamps', () async {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 2,
        windowSizeMs: 100,
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // Fill the window
      await testInterceptor.onRequest(options, handler);
      await testInterceptor.onRequest(options, handler);

      // Wait for window to expire
      await Future.delayed(const Duration(milliseconds: 150));

      // Should not be delayed
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(handler.nextCalled, isTrue);
    });

    test('should respect max delay limit', () async {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 1,
        windowSizeMs: 10000, // 10 seconds
        maxDelayMs: 100, // Very short max delay
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // First request fills the window
      await testInterceptor.onRequest(options, handler);

      // Second request should be delayed but not exceed maxDelayMs
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      expect(stopwatch.elapsedMilliseconds, greaterThan(80));
      expect(handler.nextCalled, isTrue);
    });

    test('should handle multiple requests within window correctly', () async {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 3,
        windowSizeMs: 1000,
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // First 3 requests should go through quickly
      for (var i = 0; i < 3; i++) {
        final stopwatch = Stopwatch()..start();
        await testInterceptor.onRequest(options, handler);
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      }

      // 4th request should be delayed
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(500));
      expect(handler.nextCalled, isTrue);
    });
  });
}

class MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(
    Response response, [
    bool callFollowingResponseInterceptor = false,
  ]) {}

  void reset() {
    nextCalled = false;
  }
}
