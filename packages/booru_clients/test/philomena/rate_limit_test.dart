import 'package:booru_clients/philomena.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';

import 'mock_philomena_server.dart';

void main() {
  group('Rate Limit Simulation Tests', () {
    late MockPhilomenaServer mockServer;
    late String baseUrl;

    setUpAll(() async {
      mockServer = MockPhilomenaServer();
      baseUrl = await mockServer.start();
    });

    tearDownAll(() async {
      await mockServer.stop();
    });

    setUp(() {
      mockServer.reset();
    });

    test('Mock server should handle rate limits', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(
        PhilomenaRateLimitInterceptor(
          config: PhilomenaRateLimitConfig(
            normalRequestsLimit: 2, // Low for testing
            searchRequestsLimit: 1,
          ),
        ),
      );
      final client = PhilomenaClient(
        dio: dio,
        baseUrl: baseUrl,
      );

      // First request should succeed
      final result1 = await client.getImage(123);
      expect(result1, isNotNull);

      // Second request should succeed
      final result2 = await client.getImage(124);
      expect(result2, isNotNull);

      // Third request should be rate limited by our interceptor
      await expectLater(
        client.getImage(125),
        throwsA(isA<DioException>()),
      );
    });

    test('Mock server should simulate 501 challenge', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(PhilomenaRateLimitInterceptor());

      final client = PhilomenaClient(baseUrl: baseUrl, dio: dio);

      // Trigger challenge
      mockServer.triggerChallenge();

      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );

      // After challenge, should be in backoff
      mockServer.reset(); // Stop forcing challenge

      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );
    });

    test('Mock server should simulate 500 block', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(PhilomenaRateLimitInterceptor());
      final client = PhilomenaClient(baseUrl: baseUrl, dio: dio);

      // Trigger block
      mockServer.triggerBlock();

      expect(
        () => client.getImage(123),
        throwsA(isA<DioException>()),
      );
    });

    test('Challenge backoff should last configured duration', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(
        PhilomenaRateLimitInterceptor(
          config: const PhilomenaRateLimitConfig(
            challengeBackoffSeconds: 1, // Short for testing
          ),
        ),
      );
      final client = PhilomenaClient(baseUrl: baseUrl, dio: dio);

      // Trigger challenge
      mockServer.triggerChallenge();
      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );

      // Stop forcing challenge but should still be in backoff
      mockServer.reset();
      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );

      // Wait for backoff to expire
      await Future.delayed(const Duration(milliseconds: 1100));

      // Should work now
      final result = await client.getImage(123);
      expect(result, isNotNull);
    });

    test('Block backoff should last configured duration', () async {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(
        PhilomenaRateLimitInterceptor(
          config: const PhilomenaRateLimitConfig(
            blockBackoffSeconds: 1, // Use seconds instead
            challengeBackoffSeconds: 2, // Reuse this field for block testing
          ),
        ),
      );
      final client = PhilomenaClient(baseUrl: baseUrl, dio: dio);

      // Trigger block
      mockServer.triggerBlock();
      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );

      // Stop forcing block but should still be in backoff
      mockServer.reset();
      await expectLater(
        client.getImage(123),
        throwsA(isA<DioException>()),
      );

      // Wait for backoff to expire
      await Future.delayed(const Duration(milliseconds: 2100));

      // Should work now
      final result = await client.getImage(123);
      expect(result, isNotNull);
    });
  });
}
