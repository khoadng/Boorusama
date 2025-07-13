import 'package:booru_clients/src/danbooru/danbooru_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  group('DanbooruRateLimitInterceptor', () {
    late DanbooruRateLimitInterceptor interceptor;
    late MockRequestInterceptorHandler handler;

    setUp(() {
      interceptor = DanbooruRateLimitInterceptor();
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
      final config = DanbooruRateLimitConfig(requestsPerSecond: 2);
      final testInterceptor = DanbooruRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // Fill the bucket
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
      final config = DanbooruRateLimitConfig(
        requestsPerSecond: 2,
        windowSizeMs: 100,
      );
      final testInterceptor = DanbooruRateLimitInterceptor(config: config);
      final options = RequestOptions(path: '/test', method: 'GET');

      // Fill the bucket
      await testInterceptor.onRequest(options, handler);
      await testInterceptor.onRequest(options, handler);

      // Wait for window to expire
      await Future.delayed(Duration(milliseconds: 150));

      // Should not be delayed
      handler.reset();
      final stopwatch = Stopwatch()..start();
      await testInterceptor.onRequest(options, handler);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
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
