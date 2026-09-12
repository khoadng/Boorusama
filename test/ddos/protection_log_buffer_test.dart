import 'dart:typed_data';

import 'package:boorusama/core/ddos/diagnostics/data.dart';

import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/ddos/handler/types.dart';
import 'package:boorusama/core/ddos/solver/types.dart';
import 'package:boorusama/core/http/client/src/interceptors/dio_protection_interceptor.dart';
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'protection_solver_test.dart' show FakeCookieJar, FakeUserAgentProvider;

void main() {
  for (final status in [200, 404]) {
    test('ordinary HTTP $status requests emit no verification logs', () async {
      final output = AppLogger();
      final logger = AppLogger(output: output);
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final dio = Dio()..httpClientAdapter = _Adapter(status);
      addTearDown(dio.close);
      dio.interceptors.add(
        DioProtectionInterceptor(
          dio: dio,
          protectionHandler: HttpProtectionHandler(
            cookieJar: LazyAsync(() async => FakeCookieJar()),
            contextProvider: () => _Context(),
            orchestrator: ProtectionOrchestrator(
              detectors: [CloudflareDetector(), AftDetector()],
              solvers: [],
              userAgentProvider: FakeUserAgentProvider(),
            ),
            onEvent: recorder.record,
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        if (status == 200) {
          await dio.get<dynamic>('https://example.com/image/$i.jpg');
        } else {
          await expectLater(
            dio.get<dynamic>('https://example.com/image/$i.jpg'),
            throwsA(isA<DioException>()),
          );
        }
      }
      expect(logger.logs, isEmpty);
      expect(output.logs, isEmpty);
    });
  }

  test(
    'detection flushes preceding context once, preserving capture-time timestamps',
    () {
      final logger = AppLogger();
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final attempt = ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: recorder.record,
      );
      attempt.record(const AttemptStarted());
      attempt.record(
        const RequestSent(method: 'GET', backend: 'test', retry: false),
        sensitive: ProtectionRequestDetails(
          Uri.parse('https://example.com/post.json?key=SECRET'),
        ),
      );
      final beforeDetection = DateTime.now();
      expect(logger.logs, isEmpty);
      attempt.record(
        const ResponseReceived(
          status: 403,
          retry: false,
          errorType: 'badResponse',
        ),
      );
      attempt.record(
        const DetectorEvaluated(type: 'cloudflare', score: 1, threshold: 0.3),
      );
      expect(logger.logs, hasLength(4));
      expect(logger.logs.first.dateTime.isAfter(beforeDetection), isFalse);
      expect(logger.logs[1].message, contains('/post.json'));
      expect(logger.dump(), contains('SECRET'));
      attempt.record(const SolverReportedResult(false));
      expect(logger.logs, hasLength(5));
    },
  );

  test(
    'redaction preserves sensitive pending context for later inclusion',
    () {
      final logger = AppLogger()
        ..applyOptions(
          LogOptions.defaults,
        );
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final attempt = ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: recorder.record,
      );
      attempt.record(
        const RequestSent(method: 'GET', backend: 'test', retry: false),
        sensitive: ProtectionRequestDetails(
          Uri.parse('https://example.com?key=OLD_SECRET'),
        ),
      );
      logger.applyOptions(const LogOptions(redactSensitiveDetails: true));
      logger.applyOptions(
        LogOptions.defaults,
      );
      attempt.record(
        const DetectorEvaluated(type: 'cloudflare', score: 1, threshold: 0.3),
      );
      expect(logger.dump(), contains('OLD_SECRET'));
      attempt.record(
        const RequestSent(method: 'GET', backend: 'test', retry: true),
        sensitive: ProtectionRequestDetails(
          Uri.parse('https://example.com?key=NEW_SECRET'),
        ),
      );
      expect(logger.dump(), contains('NEW_SECRET'));
    },
  );

  test(
    'a recovery failure publishes context, while a detector miss never prints as a failure',
    () {
      final logger = AppLogger();
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final attempt = ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: recorder.record,
      );
      attempt.record(const AttemptStarted());
      attempt.record(
        const ProtectionOperationFailed(
          ProtectionOperation.prepareHeaders,
          'StateError',
        ),
      );
      expect(logger.logs, hasLength(2));
      attempt.record(const RecoveryStopped(RecoveryStopReason.noDetector));
      expect(logger.logs, hasLength(2));
    },
  );

  test('unresolved ordinary requests retain only bounded context', () {
    final logger = AppLogger();
    final recorder = ProtectionLogRecorder(logger);
    addTearDown(recorder.dispose);
    final attempts = List.generate(
      65,
      (_) => ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: recorder.record,
      )..record(const AttemptStarted()),
    );
    expect(logger.logs, isEmpty);
    attempts.first.record(
      const DetectorEvaluated(type: 'cloudflare', score: 1, threshold: 0.3),
    );
    // The oldest unresolved request's context was evicted, not retained forever.
    expect(logger.logs, hasLength(1));
    final recent = attempts.last;
    for (var i = 0; i < 25; i++) {
      recent.record(const CookieLookupCompleted(CookieStore.requestJar, 0));
    }
    recent.record(
      const DetectorEvaluated(type: 'cloudflare', score: 1, threshold: 0.3),
    );
    expect(logger.logs, hasLength(17));
  });
}

class _Context extends Fake implements BuildContext {}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status);
  final int status;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('ordinary response', status);
  @override
  void close({bool force = false}) {}
}
