// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/ddos/diagnostics/data.dart';
import 'package:boorusama/core/ddos/solver/types.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/types.dart';

void main() {
  test(
    '31 unchanged polls produce state, heartbeats, and accurate close totals',
    () {
      final h = _Harness();
      for (var i = 1; i <= 31; i++) {
        h.poll(i, length: 100 + i);
      }
      expect(h.logger.logs, hasLength(3));
      expect(h.logger.dump(), contains('timerState=heartbeat'));
      h.emit(const DialogClosed(true), check: null);
      expect(
        h.logger.logs.last.message,
        contains('timerChecks=31 suppressedTimerChecks=28'),
      );
    },
  );

  test(
    'cookie and page marker changes publish immediately, isolated by solver',
    () {
      final h = _Harness();
      h.poll(1);
      h.poll(2);
      h.poll(3, cookies: 2);
      h.poll(4, cookies: 2, marker: '403 forbidden');
      h.solver = 2;
      h.poll(5);
      expect(h.logger.logs, hasLength(4));
    },
  );

  test(
    'manual checks, errors, overlap, and successful completion stay detailed',
    () {
      final h = _Harness();
      h.poll(1, trigger: CheckTrigger.manual);
      expect(h.logger.logs, hasLength(4));
      h.start(2);
      h.emit(
        const ProtectionOperationFailed(
          ProtectionOperation.pageSource,
          'StateError',
        ),
      );
      expect(h.logger.logs, hasLength(6));
      h.emit(
        const CompletionCheckFinished(
          outcome: CheckOutcome.failed,
          alreadyCompleted: false,
        ),
      );
      h.start(3);
      h.start(4, active: 2);
      expect(h.logger.dump(), contains('activeChecks=2'));
      h.emit(
        const CompletionCheckFinished(
          outcome: CheckOutcome.pageAccepted,
          alreadyCompleted: false,
        ),
      );
      expect(h.logger.logs.last.message, contains('pageAccepted'));
    },
  );

  test(
    'redaction mid-check preserves pending page contents',
    () {
      final h = _Harness();
      h.logger.applyOptions(
        LogOptions.defaults,
      );
      h.start(1);
      h.emit(
        const PageEvaluated(
          evaluation: PageEvaluation.failure('failure!'),
          length: 10,
        ),
        sensitive: const ProtectionPageContents('PRIVATE_PAGE'),
      );
      h.logger.applyOptions(const LogOptions(redactSensitiveDetails: true));
      h.logger.applyOptions(
        LogOptions.defaults,
      );
      h.emit(
        const CompletionCheckFinished(
          outcome: CheckOutcome.pageRejected,
          alreadyCompleted: false,
        ),
      );
      expect(h.logger.dump(), contains('PRIVATE_PAGE'));
    },
  );

  test('navigation resets suppression and keeps pending context visible', () {
    final h = _Harness();
    h.poll(1);
    h.poll(2);
    h.emit(
      const PageNavigationObserved(PageNavigationPhase.started, 'example.com'),
      check: null,
    );
    h.poll(3);
    expect(h.logger.logs, hasLength(3));
  });

  test(
    'published state retains opted-in snapshot and acceptance is never suppressed',
    () {
      final h = _Harness();
      h.logger.applyOptions(
        LogOptions.defaults,
      );
      h.start(1);
      h.emit(
        const PageEvaluated(
          evaluation: PageEvaluation.failure('failure!'),
          length: 10,
        ),
        sensitive: const ProtectionPageContents('PRIVATE_PAGE'),
      );
      h.emit(
        const CompletionCheckFinished(
          outcome: CheckOutcome.pageRejected,
          alreadyCompleted: false,
        ),
      );
      expect(h.logger.dump(), contains('PRIVATE_PAGE'));
      expect(h.logger.logs.single.safeMessage, isNot(contains('PRIVATE_PAGE')));
      h.start(2);
      h.emit(
        const PageEvaluated(
          evaluation: PageEvaluation.noKnownMarkers(),
          length: 100,
        ),
      );
      h.emit(
        const CompletionCheckFinished(
          outcome: CheckOutcome.pageAccepted,
          alreadyCompleted: false,
        ),
      );
      expect(h.logger.logs, hasLength(4));
    },
  );

  test('closing flushes unfinished checks and resets the session', () {
    final h = _Harness();
    h.poll(1);
    h.start(2);
    h.emit(const DialogClosed(false), check: null);
    expect(h.logger.logs, hasLength(3));
    h.poll(3);
    expect(h.logger.logs, hasLength(4));
  });
}

class _Harness {
  _Harness() {
    addTearDown(recorder.dispose);
  }
  final logger = AppLogger();
  late final recorder = ProtectionLogRecorder(logger);
  var solver = 1;
  var currentCheck = 1;
  var second = 0;

  void emit(
    ProtectionEvent event, {
    int? check = -1,
    ProtectionSensitiveDetails? sensitive,
  }) {
    recorder.record(
      ProtectionRecord(
        scope: ProtectionScope(
          host: 'example.com',
          solverId: solver,
          checkId: check == -1 ? currentCheck : check,
        ),
        event: event,
        elapsed: Duration(seconds: second),
      ),
      sensitive: sensitive,
    );
  }

  void start(
    int id, {
    CheckTrigger trigger = CheckTrigger.timer,
    int active = 1,
  }) {
    currentCheck = id;
    second = id;
    emit(CompletionCheckStarted(trigger: trigger, activeChecks: active));
  }

  void poll(
    int id, {
    int length = 100,
    int cookies = 1,
    String marker = 'failure!',
    CheckTrigger trigger = CheckTrigger.timer,
  }) {
    start(id, trigger: trigger);
    emit(
      CookiesObserved(
        count: cookies,
        matching: 0,
        changed: false,
        currentHost: 'example.com',
      ),
    );
    emit(
      PageEvaluated(evaluation: PageEvaluation.failure(marker), length: length),
    );
    emit(
      const CompletionCheckFinished(
        outcome: CheckOutcome.pageRejected,
        alreadyCompleted: false,
      ),
    );
  }
}
