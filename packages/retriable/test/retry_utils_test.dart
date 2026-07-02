import 'package:dio/dio.dart';
import 'package:retriable/retriable.dart';
import 'package:test/test.dart';

import 'mock_backend.dart';

void main() {
  group('tryGetResponse with local backend', () {
    late Dio dio;
    late MockBackend backend;

    setUp(() async {
      dio = Dio();
      backend = await MockBackend.start();
    });

    tearDown(() async {
      await backend.close();
    });

    test('should successfully get a response', () async {
      backend.script('/success', [200]);

      final response = await tryGetResponse<String>(
        backend.uri('/success'),
        dio: dio,
        options: _plainTextOptions,
      );

      expect(response, isNotNull);
      expect(response?.statusCode, 200);
      expect(response?.data, 'ok');
      expect(backend.requestCount('/success'), 1);
    });

    test('should retry all transient HTTP responses until success', () async {
      for (final statusCode in _transientHttpResponseStatusCodes) {
        final path = '/transient-$statusCode';
        backend.script(
          path,
          [statusCode, statusCode, 200],
          successBody: 'recovered from $statusCode',
        );

        final response = await tryGetResponse<String>(
          backend.uri(path),
          dio: dio,
          fetchStrategy: _fastFetchStrategy(maxAttempts: 3),
          options: _plainTextOptions,
        );

        expect(response?.statusCode, 200);
        expect(response?.data, 'recovered from $statusCode');
        expect(backend.requestCount(path), 3);
      }
    });

    test('should throw after max attempts for transient responses', () async {
      backend.script('/give-up', [500, 500, 500, 200]);

      await expectLater(
        () => tryGetResponse<String>(
          backend.uri('/give-up'),
          dio: dio,
          fetchStrategy: _fastFetchStrategy(maxAttempts: 3),
          options: _plainTextOptions,
        ),
        throwsA(
          isA<FetchFailure>()
              .having((e) => e.httpStatusCode, 'httpStatusCode', 500)
              .having((e) => e.attemptCount, 'attemptCount', 3),
        ),
      );
      expect(backend.requestCount('/give-up'), 3);
    });

    test('should return null after max attempts when silent', () async {
      backend.script('/silent', [503, 503, 503]);

      final response = await tryGetResponse<String>(
        backend.uri('/silent'),
        dio: dio,
        fetchStrategy: _fastFetchStrategy(maxAttempts: 2, silent: true),
        options: _plainTextOptions,
      );

      expect(response, isNull);
      expect(backend.requestCount('/silent'), 2);
    });

    test('should not retry non-transient HTTP responses', () async {
      backend.script('/not-found', [404, 200]);

      await expectLater(
        () => tryGetResponse<String>(
          backend.uri('/not-found'),
          dio: dio,
          fetchStrategy: _fastFetchStrategy(maxAttempts: 3),
          options: _plainTextOptions,
        ),
        throwsA(
          isA<FetchFailure>()
              .having((e) => e.httpStatusCode, 'httpStatusCode', 404)
              .having((e) => e.attemptCount, 'attemptCount', 1),
        ),
      );
      expect(backend.requestCount('/not-found'), 1);
    });

    test('should retry custom transient HTTP responses', () async {
      backend.script('/custom-transient', [418, 200]);

      final response = await tryGetResponse<String>(
        backend.uri('/custom-transient'),
        dio: dio,
        fetchStrategy: _fastFetchStrategy(
          maxAttempts: 2,
          transientHttpStatusCodePredicate: (statusCode) => statusCode == 418,
        ),
        options: _plainTextOptions,
      );

      expect(response?.statusCode, 200);
      expect(response?.data, 'ok');
      expect(backend.requestCount('/custom-transient'), 2);
    });

    test('should respect cancellation token', () {
      final cancelToken = CancelToken()..cancel();

      expect(
        () => tryGetResponse<String>(
          backend.uri('/cancelled'),
          dio: dio,
          cancelToken: cancelToken,
          options: _plainTextOptions,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}

final _plainTextOptions = Options(responseType: ResponseType.plain);

Iterable<int> get _transientHttpResponseStatusCodes =>
    defaultTransientHttpStatusCodes.where((statusCode) => statusCode != 0);

FetchStrategyBuilder _fastFetchStrategy({
  required int maxAttempts,
  bool? silent,
  bool Function(int statusCode)? transientHttpStatusCodePredicate,
}) => FetchStrategyBuilder(
  maxAttempts: maxAttempts,
  initialPauseBetweenRetries: Duration.zero,
  exponentialBackoffMultiplier: 1,
  silent: silent,
  transientHttpStatusCodePredicate:
      transientHttpStatusCodePredicate ??
      ((statusCode) => defaultTransientHttpStatusCodes.contains(statusCode)),
);
