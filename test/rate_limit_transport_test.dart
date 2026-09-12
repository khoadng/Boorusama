import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:boorusama/core/http/client/types.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter({this.retryAfter = '1', this.status = 429});
  final String? retryAfter;
  final int status;
  final clock = Stopwatch()..start();
  final starts = <int>[];
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    starts.add(clock.elapsedMilliseconds);
    paths.add(options.path);
    return ResponseBody.fromString(
      '{}',
      starts.length == 1 ? status : 200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        if (retryAfter != null) 'retry-after': [retryAfter!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('concurrent clients share request pacing', () async {
    final adapter = RecordingAdapter(status: 200);
    final limiter = SlidingWindowRateLimitInterceptor(
      config: SlidingWindowRateLimitConfig(
        requestsPerWindow: 1,
        windowSizeMs: 100,
        resolver: (_) => true,
      ),
    );
    final clients = List.generate(
      2,
      (_) => Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(limiter),
    );
    addTearDown(() {
      for (final client in clients) {
        client.close(force: true);
      }
    });
    await Future.wait(
      List.generate(
        4,
        (i) => clients[i % 2].get('https://example.test/download/$i.png'),
      ),
    );
    expect(adapter.starts, hasLength(4));
    for (var i = 1; i < adapter.starts.length; i++) {
      expect(
        adapter.starts[i] - adapter.starts[i - 1],
        greaterThanOrEqualTo(90),
      );
    }
  });

  test('excluded requests bypass queued admission', () async {
    final adapter = RecordingAdapter(status: 200);
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        SlidingWindowRateLimitInterceptor(
          config: const SlidingWindowRateLimitConfig(
            requestsPerWindow: 1,
            windowSizeMs: 200,
          ),
        ),
      );
    addTearDown(() => dio.close(force: true));
    await dio.get('https://example.test/first');
    final pending = dio.get('https://example.test/second');
    await dio.get('https://example.test/image.png');
    await pending;
    expect(adapter.paths, [
      'https://example.test/first',
      'https://example.test/image.png',
      'https://example.test/second',
    ]);
  });

  for (final headerCase in ['missing', 'malformed', 'negative', 'date']) {
    test('handles $headerCase Retry-After header', () async {
      final actualHeader = switch (headerCase) {
        'missing' => null,
        'malformed' => 'invalid',
        'negative' => '-5',
        'date' => HttpDate.format(
          DateTime.now().toUtc().add(const Duration(seconds: 2)),
        ),
        _ => throw StateError('Unknown header case: $headerCase'),
      };
      final adapter = RecordingAdapter(retryAfter: actualHeader);
      final dio = Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(
          SlidingWindowRateLimitInterceptor(
            config: const SlidingWindowRateLimitConfig(
              requestsPerWindow: 10,
              windowSizeMs: 100,
              retryAfterFallback: Duration(milliseconds: 200),
            ),
          ),
        );
      addTearDown(() => dio.close(force: true));
      await expectLater(
        dio.get('https://example.test/first'),
        throwsA(isA<DioException>()),
      );
      await dio.get('https://example.test/second');
      expect(
        adapter.starts[1] - adapter.starts[0],
        greaterThanOrEqualTo(headerCase == 'date' ? 990 : 190),
      );
    });
  }

  test(
    'extensions affect queued clients and cancellation sends nothing',
    () async {
      final limiter = SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 1,
          windowSizeMs: 100,
          retryAfterFallback: Duration(milliseconds: 200),
        ),
      );
      final adapter = RecordingAdapter();
      final clients = List.generate(
        2,
        (_) => Dio()
          ..httpClientAdapter = adapter
          ..interceptors.add(limiter),
      );
      addTearDown(() {
        for (final client in clients) {
          client.close(force: true);
        }
      });
      await expectLater(
        clients[0].get('https://example.test/first'),
        throwsA(isA<DioException>()),
      );
      final token = CancelToken();
      final cancelled = clients[0].get(
        'https://example.test/cancel',
        cancelToken: token,
      );
      final check = expectLater(
        cancelled,
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      final requests = Future.wait([
        clients[1].get('https://example.test/second'),
        clients[0].get('https://example.test/third'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      token.cancel();
      signal(limiter, '1');
      signal(limiter, '0'); // Must not shorten the extended deadline.
      await check;
      await requests;
      expect(adapter.starts, hasLength(3));
      expect(adapter.starts[1] - adapter.starts[0], greaterThanOrEqualTo(1240));
      expect(adapter.starts[2] - adapter.starts[1], greaterThanOrEqualTo(90));
    },
  );

  test('429 during normal rate wait blocks admission', () async {
    final adapter = RecordingAdapter(status: 200);
    final limiter = SlidingWindowRateLimitInterceptor(
      config: const SlidingWindowRateLimitConfig(
        requestsPerWindow: 1,
        windowSizeMs: 100,
        retryAfterFallback: Duration(milliseconds: 200),
      ),
    );
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(limiter);
    addTearDown(() => dio.close(force: true));
    await dio.get('https://example.test/first');
    final pending = dio.get('https://example.test/second');
    await Future<void>.delayed(const Duration(milliseconds: 25));
    signal(limiter, '1');
    await pending;
    expect(adapter.starts[1] - adapter.starts[0], greaterThanOrEqualTo(1015));
  });

  test('server cooldown remains opt-in', () async {
    final adapter = RecordingAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        SlidingWindowRateLimitInterceptor(
          config: const SlidingWindowRateLimitConfig(
            requestsPerWindow: 10,
            windowSizeMs: 100,
          ),
        ),
      );
    addTearDown(() => dio.close(force: true));
    await expectLater(
      dio.get('https://example.test/first'),
      throwsA(isA<DioException>()),
    );
    await dio.get('https://example.test/second');
    expect(adapter.starts[1] - adapter.starts[0], lessThan(500));
  });

  for (final accept429 in [false, true]) {
    test('cooldown applies when 429 is accepted=$accept429', () async {
      final adapter = RecordingAdapter();
      final limiter = SlidingWindowRateLimitInterceptor(
        config: const SlidingWindowRateLimitConfig(
          requestsPerWindow: 10,
          windowSizeMs: 100,
          retryAfterFallback: Duration(milliseconds: 200),
        ),
      );
      final dio = Dio()
        ..httpClientAdapter = adapter
        ..interceptors.add(limiter);
      addTearDown(() => dio.close(force: true));
      final first = dio.get(
        'https://example.test/first',
        options: Options(validateStatus: (code) => accept429 || code == 200),
      );
      if (accept429) {
        expect((await first).statusCode, 429);
      } else {
        await expectLater(first, throwsA(isA<DioException>()));
      }
      await dio.get('https://example.test/second');
      expect(adapter.starts, hasLength(2));
      expect(adapter.starts[1] - adapter.starts[0], greaterThanOrEqualTo(990));
    });
  }
}

void signal(SlidingWindowRateLimitInterceptor limiter, String header) {
  limiter.onResponse(
    Response(
      requestOptions: RequestOptions(path: 'https://example.test/inflight'),
      statusCode: 429,
      headers: Headers.fromMap({
        'retry-after': [header],
      }),
    ),
    ResponseInterceptorHandler(),
  );
}
