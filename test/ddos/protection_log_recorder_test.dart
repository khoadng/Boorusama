import 'package:boorusama/core/ddos/diagnostics/providers.dart';
import 'package:boorusama/core/debug/providers.dart';
import 'package:boorusama/foundation/loggers/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boorusama/core/ddos/diagnostics/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';
import 'package:boorusama/core/ddos/solver/types.dart';

void main() {
  test('clear removes pending attempt and poll entries before publication', () {
    final logger = AppLogger();
    final recorder = ProtectionLogRecorder(logger);
    addTearDown(recorder.dispose);
    final attempt = ProtectionAttempt(
      source: ProtectionSource.dio,
      host: 'example.com',
      onEvent: recorder.record,
    );
    attempt.record(const AttemptStarted());
    final session = ProtectionSession(
      host: 'example.com',
      type: 'cloudflare',
      onEvent: recorder.record,
    );
    final check = session.beginCheck(CheckTrigger.timer);
    check.record(
      const PageEvaluated(
        evaluation: PageEvaluation.challenge('OLD_MARKER'),
        length: 10,
      ),
    );
    expect(logger.logs, isEmpty);
    logger.clearLogsAtOrBelow(LogLevel.info);
    attempt.record(
      const DetectorEvaluated(type: 'cloudflare', score: 1, threshold: 0.3),
    );
    check.finish(CheckOutcome.pageRejected, alreadyCompleted: false);
    expect(logger.logs, hasLength(2));
    expect(logger.dump(), isNot(contains('attempt started')));
    expect(logger.dump(), isNot(contains('OLD_MARKER')));
  });

  test(
    'provider owns recorder lifetime and replacement starts with empty buffers',
    () {
      final logger = AppLogger();
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(logger),
        ],
      );
      addTearDown(container.dispose);
      final recorder = container.read(protectionLogRecorderProvider);
      const record = ProtectionRecord(
        scope: ProtectionScope(host: 'example.com', attemptId: 1),
        event: AttemptStarted(),
        elapsed: Duration.zero,
      );
      recorder.record(record);
      container.invalidate(protectionLogRecorderProvider);
      final replacement = container.read(protectionLogRecorderProvider);
      expect(() => recorder.record(record), throwsStateError);
      replacement.record(
        const ProtectionRecord(
          scope: ProtectionScope(host: 'example.com', attemptId: 1),
          event: DetectorEvaluated(
            type: 'cloudflare',
            score: 1,
            threshold: 0.3,
          ),
          elapsed: Duration(seconds: 1),
        ),
      );
      expect(logger.logs, hasLength(1));
      logger.applyCaptureOptions(
        const LogCaptureOptions(includeSensitiveDetails: true),
      );
      logger.applyCaptureOptions(LogCaptureOptions.defaults);
      expect(logger.logs, hasLength(1));
    },
  );

  test(
    'typed recorder keeps sensitive payloads separate and honors capture changes',
    () {
      final logger = AppLogger();
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final session = ProtectionSession(
        host: 'example.com',
        type: 'cloudflare',
        onEvent: recorder.record,
      );
      final check = session.beginCheck(CheckTrigger.pageFinished);
      void emit() {
        session.record(
          const SolverStarted(),
          sensitive: ProtectionRequestDetails(
            Uri.parse(
              'https://user:USER_SECRET@example.com/path?key=QUERY_SECRET#FRAGMENT_SECRET',
            ),
            userAgent: 'UA_SECRET',
          ),
        );
        check.record(
          const PageEvaluated(
            evaluation: PageEvaluation.challenge('cf_chl'),
            length: 14,
          ),
          sensitive: const ProtectionPageContents('cf_chl BODY_SECRET'),
        );
        session.record(
          const PageNavigationObserved(
            PageNavigationPhase.finished,
            'example.com',
          ),
          sensitive: const ProtectionNavigationDetails(
            'https://example.com/login?token=NAV_SECRET',
          ),
        );
      }

      emit();
      expect(logger.dump(), isNot(contains('SECRET')));
      expect(logger.dump(), contains('reason=challengeMarker'));
      expect(logger.dump(), contains('check=${check.id}'));
      expect(logger.dump(), contains('elapsedMs='));
      expect(
        logger.logs.every((entry) => entry.sensitiveMessage == null),
        isTrue,
      );
      logger.applyCaptureOptions(
        const LogCaptureOptions(includeSensitiveDetails: true),
      );
      emit();
      expect(logger.dump(), contains('BODY_SECRET'));
      expect(logger.dump(), contains('QUERY_SECRET'));
      expect(logger.dump(), contains('NAV_SECRET'));
      expect(
        logger.logs.map((entry) => entry.safeMessage).join('\n'),
        isNot(contains('SECRET')),
      );
      logger.applyCaptureOptions(LogCaptureOptions.defaults);
      expect(logger.dump(), isNot(contains('SECRET')));
      check.finish(CheckOutcome.pageRejected, alreadyCompleted: false);
    },
  );

  test(
    'credential comparison events have no credential payload even with capture enabled',
    () {
      final logger = AppLogger()
        ..applyCaptureOptions(
          const LogCaptureOptions(includeSensitiveDetails: true),
        );
      final recorder = ProtectionLogRecorder(logger);
      addTearDown(recorder.dispose);
      final attempt = ProtectionAttempt(
        source: ProtectionSource.dio,
        host: 'example.com',
        onEvent: recorder.record,
      );
      attempt.session = ProtectionSession(
        host: 'example.com',
        type: 'cloudflare',
        onEvent: recorder.record,
      )..observeCompletion({'cf_clearance': 'COOKIE_SECRET'}, 'UA_SECRET');
      attempt.observeHeaders({
        'Cookie': 'cf_clearance=COOKIE_SECRET',
        'User-Agent': 'UA_SECRET',
      });
      expect(logger.dump(), contains('solverCookiesMatch=match'));
      expect(logger.dump(), isNot(contains('SECRET')));
      expect(
        logger.logs.every((entry) => entry.sensitiveMessage == null),
        isTrue,
      );
    },
  );
}
