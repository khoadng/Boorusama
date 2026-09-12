import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:retriable/retriable.dart';
import 'package:test/test.dart';

void main() {
  for (final dateHeader in [false, true]) {
    test(
      'waits for Retry-After expressed as ${dateHeader ? 'a date' : 'seconds'}',
      () async {
        final allowedAt = dateHeader
            ? DateTime.fromMillisecondsSinceEpoch(
                (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2) * 1000,
                isUtc: true,
              )
            : null;
        final arrivals = <DateTime>[];
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final dio = Dio();
        addTearDown(() async {
          dio.close(force: true);
          await server.close(force: true);
        });
        server.listen((request) async {
          arrivals.add(DateTime.now());
          request.response.statusCode = arrivals.length == 1 ? 503 : 200;
          if (arrivals.length == 1) {
            request.response.headers.set(
              'Retry-After',
              allowedAt == null ? '1' : formatHttpDate(allowedAt),
            );
          }
          request.response.write('fixture');
          await request.response.close();
        });
        final result = await tryGetResponse<String>(
          Uri.parse('http://127.0.0.1:${server.port}/image.png'),
          dio: dio,
          fetchStrategy: const FetchStrategyBuilder(
            initialPauseBetweenRetries: Duration(milliseconds: 10),
          ),
        );
        expect(result?.statusCode, 200);
        expect(arrivals, hasLength(2));
        expect(
          arrivals[1].isBefore(
            allowedAt ?? arrivals[0].add(const Duration(seconds: 1)),
          ),
          isFalse,
        );
      },
    );
  }

  for (final retry429 in [false, true]) {
    test('uses configured status policy when retry429=$retry429', () async {
      var attempts = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              attempts++;
              if (attempts == 1) {
                handler.reject(
                  DioException(
                    requestOptions: request,
                    response: Response(
                      requestOptions: request,
                      statusCode: retry429 ? 429 : 503,
                    ),
                  ),
                );
              } else {
                handler.resolve(
                  Response(
                    requestOptions: request,
                    statusCode: 200,
                    data: 'ok',
                  ),
                );
              }
            },
          ),
        );
      addTearDown(dio.close);
      final result = tryGetResponse<String>(
        Uri.parse('https://fixture.test/image.png'),
        dio: dio,
        fetchStrategy: FetchStrategyBuilder(
          transientHttpStatusCodePredicate: (status) => status == 429,
          initialPauseBetweenRetries: Duration.zero,
        ),
      );
      if (retry429) {
        expect((await result)?.statusCode, 200);
        expect(attempts, 2);
      } else {
        await expectLater(result, throwsA(isA<FetchFailure>()));
        expect(attempts, 1);
      }
    });
  }

  test(
    'does not retry before server delay when fetch budget is insufficient',
    () async {
      var attempts = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: request,
                  response: Response(
                    requestOptions: request,
                    statusCode: 503,
                    headers: Headers.fromMap({
                      'retry-after': ['120'],
                    }),
                  ),
                ),
              );
            },
          ),
        );
      addTearDown(dio.close);
      await expectLater(
        tryGetResponse<String>(
          Uri.parse('https://fixture.test/image.png'),
          dio: dio,
          fetchStrategy: const FetchStrategyBuilder(
            totalFetchTimeout: Duration(seconds: 1),
            initialPauseBetweenRetries: Duration.zero,
          ),
        ).timeout(const Duration(seconds: 2)),
        throwsA(isA<FetchFailure>()),
      );
      expect(attempts, 1);
    },
  );
}
