import 'package:dio/dio.dart';
import 'package:http_client_helper/http_client_helper.dart' hide Response;
import 'package:retriable/retriable.dart';
import 'package:test/test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio();
  });

  group('tryGetResponse', () {
    test('should successfully get JSON response', () async {
      final response = await tryGetResponse<Map<String, dynamic>>(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        dio: dio,
      );

      expect(response, isNotNull);
      expect(response!.data, isA<Map<String, dynamic>>());
      expect(response.statusCode, equals(200));
    });

    test('should retry on server error', () async {
      final response = await tryGetResponse<Map<String, dynamic>>(
        Uri.parse('https://httpstat.us/500'),
        dio: dio,
        fetchStrategy: const FetchStrategyBuilder(
          maxAttempts: 2,
          initialPauseBetweenRetries: Duration(milliseconds: 10),
          exponentialBackoffMultiplier: 1.1,
        ),
      ).catchError((e) => null);

      expect(response, isNull);
    });

    test('should respect max attempts', () async {
      var attempts = 0;
      final mockDio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                  ),
                ),
              );
            },
          ),
        );

      await tryGetResponse<Map<String, dynamic>>(
        Uri.parse('https://example.com'),
        dio: mockDio,
        fetchStrategy: const FetchStrategyBuilder(
          maxAttempts: 3,
          initialPauseBetweenRetries: Duration(milliseconds: 100),
        ),
      ).catchError((e) => null);

      expect(attempts, equals(3));
    });

    test('should handle timeouts', () async {
      final mockDio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionTimeout,
                ),
              );
            },
          ),
        );

      final response = await tryGetResponse<Map<String, dynamic>>(
        Uri.parse('https://example.com'),
        dio: mockDio,
      ).catchError((e) => null);

      expect(response, isNull);
    });

    test('should not retry on non-retriable status codes', () async {
      var attempts = 0;
      final mockDio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                  ),
                ),
              );
            },
          ),
        );

      await tryGetResponse<Map<String, dynamic>>(
        Uri.parse('https://example.com'),
        dio: mockDio,
      ).catchError((e) => null);

      expect(attempts, equals(1));
    });

    test('should respect cancellation token', () async {
      final cancelToken = CancellationToken();
      // ignore: cascade_invocations
      cancelToken.cancel();

      expect(
        () => tryGetResponse<Map<String, dynamic>>(
          Uri.parse('https://example.com'),
          dio: dio,
          cancelToken: cancelToken,
        ),
        throwsA(isA<OperationCanceledError>()),
      );
    });
  });
}
