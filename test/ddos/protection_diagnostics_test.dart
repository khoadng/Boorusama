import 'dart:typed_data';

import 'package:boorusama/core/ddos/handler/types.dart';
import 'package:boorusama/core/ddos/solver/types.dart';
import 'package:boorusama/core/http/client/src/interceptors/dio_protection_interceptor.dart';
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'protection_solver_test.dart'
    show FakeCookieJar, FakeUserAgentProvider, FakeHttpError;

void main() {
  test(
    'header observations distinguish missing, matching and stale credentials without values',
    () {
      final records = <ProtectionRecord>[];
      final attempt = ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: (record, {sensitive}) => records.add(record),
      );
      attempt.observeHeaders({});
      expect(
        (records.last.event as HeadersPrepared).cookies,
        CredentialMatch.unknown,
      );
      attempt.session = ProtectionSession(
        host: 'example.com',
        type: 'cloudflare',
      )..observeCompletion({'cf_clearance': 'COOKIE_SECRET=='}, 'UA_SECRET');
      attempt.observeHeaders({
        'Cookie': 'other=abc; cf_clearance=COOKIE_SECRET==',
        'User-Agent': 'UA_SECRET',
      });
      expect(
        (records.last.event as HeadersPrepared).cookies,
        CredentialMatch.match,
      );
      expect(
        (records.last.event as HeadersPrepared).userAgent,
        CredentialMatch.match,
      );
      attempt.observeHeaders({
        'cookie': 'cf_clearance=STALE_SECRET',
        'user-agent': 'OTHER_SECRET',
      });
      expect(
        (records.last.event as HeadersPrepared).cookies,
        CredentialMatch.mismatch,
      );
      expect(
        (records.last.event as HeadersPrepared).userAgent,
        CredentialMatch.mismatch,
      );
      attempt.observeHeaders({});
      expect(
        (records.last.event as HeadersPrepared).cookies,
        CredentialMatch.mismatch,
      );
    },
  );

  test(
    'recovery reports disabled, missing context and retry limit independently',
    () async {
      final records = <ProtectionRecord>[];
      HttpProtectionHandler makeHandler({int maxRetries = 3}) =>
          HttpProtectionHandler(
            orchestrator: ProtectionOrchestrator(
              detectors: [CloudflareDetector()],
              solvers: [_Solver()],
              userAgentProvider: FakeUserAgentProvider(),
            ),
            cookieJar: LazyAsync(() async => FakeCookieJar()),
            contextProvider: () => null,
            maxRetries: maxRetries,
            onEvent: (record, {sensitive}) => records.add(record),
          );
      final error = FakeHttpError();
      final handler = makeHandler();
      final attempt = handler.beginAttempt(
        error.requestUri,
        ProtectionSource.dio,
      );
      expect(await handler.handleError(error, attempt: attempt), isFalse);
      expect(
        (records.last.event as RecoveryStopped).reason,
        RecoveryStopReason.noContext,
      );
      handler.disable();
      expect(await handler.handleError(error, attempt: attempt), isFalse);
      expect(
        (records.last.event as RecoveryStopped).reason,
        RecoveryStopReason.disabled,
      );
      expect(
        await makeHandler(maxRetries: 0).handleError(error, attempt: attempt),
        isFalse,
      );
      expect(
        (records.last.event as RecoveryStopped).reason,
        RecoveryStopReason.retryLimit,
      );
    },
  );

  for (final retryStatus in [200, 403]) {
    test(
      'Dio traces solver success separately from retry status $retryStatus',
      () async {
        final records = <ProtectionRecord>[];
        final solver = _Solver();
        final handler = HttpProtectionHandler(
          orchestrator: ProtectionOrchestrator(
            detectors: [CloudflareDetector()],
            solvers: [solver],
            userAgentProvider: FakeUserAgentProvider(),
          ),
          cookieJar: LazyAsync(() async => FakeCookieJar()),
          contextProvider: () => _Context(),
          onEvent: (record, {sensitive}) => records.add(record),
        );
        final adapter = _Adapter(retryStatus);
        final dio = Dio()..httpClientAdapter = adapter;
        addTearDown(dio.close);
        dio.interceptors.add(
          DioProtectionInterceptor(protectionHandler: handler, dio: dio),
        );
        if (retryStatus == 200) {
          expect(
            (await dio.get<dynamic>(
              'https://example.com/image?key=SECRET',
            )).statusCode,
            200,
          );
        } else {
          await expectLater(
            dio.get<dynamic>('https://example.com/image?key=SECRET'),
            throwsA(isA<DioException>()),
          );
        }
        expect(adapter.requests, 2);
        expect(solver.calls, 1);
        final events = records.map((record) => record.event).toList();
        expect(events.whereType<SolverReportedResult>().single.success, isTrue);
        final retry = events.whereType<ResponseReceived>().last;
        expect(retry.retry, isTrue);
        expect(retry.status, retryStatus);
        expect(retry.errorType, retryStatus == 200 ? isNull : isNotNull);
        expect(
          events.indexWhere((event) => event is SolverReportedResult),
          lessThan(events.lastIndexOf(retry)),
        );
        expect(
          records
              .map((record) => record.scope.attemptId)
              .whereType<int>()
              .toSet(),
          hasLength(1),
        );
      },
    );
  }
}

class _Solver implements ProtectionSolver {
  var calls = 0;
  @override
  String get protectionType => 'cloudflare';
  @override
  bool get isSolving => false;
  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) async {
    calls++;
    return true;
  }

  @override
  Future<void> cancel() async {}
}

class _Context extends Fake implements BuildContext {}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.retryStatus);
  final int retryStatus;
  var requests = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    return ResponseBody.fromString(
      'cloudflare cf_chl challenge',
      requests == 1 ? 403 : retryStatus,
    );
  }

  @override
  void close({bool force = false}) {}
}
