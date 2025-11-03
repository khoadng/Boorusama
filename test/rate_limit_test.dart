// Package imports:
import 'package:dio/dio.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/http/client/types.dart';

void main() {
  group('SlidingWindowRateLimitInterceptor', () {
    late MockRequestInterceptorHandler handler;

    setUp(() {
      handler = MockRequestInterceptorHandler();
    });

    test('should skip rate limiting when resolver returns false', () async {
      bool isImageUrl(RequestOptions options) {
        return options.path.endsWith('.jpg') || options.path.endsWith('.png');
      }

      final config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 2,
        windowSizeMs: 1000,
        resolver: (options) => !isImageUrl(options), // Don't rate limit images
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);

      // Image requests should not be rate limited
      final imageOptions = RequestOptions(path: '/image.jpg', method: 'GET');

      // Make many image requests quickly
      for (var i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        await testInterceptor.onRequest(imageOptions, handler);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        expect(handler.nextCalled, isTrue);
        handler.reset();
      }
    });

    test('should apply rate limiting when resolver returns true', () async {
      bool isImageUrl(RequestOptions options) {
        return options.path.endsWith('.jpg') || options.path.endsWith('.png');
      }

      final config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 2,
        windowSizeMs: 1000,
        resolver: (options) => !isImageUrl(options), // Don't rate limit images
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);

      // API requests should be rate limited
      final apiOptions = RequestOptions(path: '/api/posts', method: 'GET');

      // Fill the window
      await testInterceptor.onRequest(apiOptions, handler);
      await testInterceptor.onRequest(apiOptions, handler);

      // Third request should be delayed
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(apiOptions, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(500));
      expect(handler.nextCalled, isTrue);
    });

    test('should delay requests when exceeding rate limit', () async {
      const config = SlidingWindowRateLimitConfig(
        requestsPerWindow: 2,
        windowSizeMs: 1000,
      );
      final testInterceptor = SlidingWindowRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'POST');

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
      final options = RequestOptions(path: '/test', method: 'PUT');

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
      final options = RequestOptions(path: '/test', method: 'DELETE');

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
      final options = RequestOptions(path: '/test', method: 'PATCH');

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
  var nextCalled = false;

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
