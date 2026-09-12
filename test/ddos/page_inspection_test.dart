import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:boorusama/core/ddos/solver/src/protection_diagnostics.dart';
import 'package:boorusama/core/ddos/solver/src/page_inspection.dart';

void main() {
  test(
    'evaluation preserves marker precedence and existing acceptance rules',
    () {
      for (final evaluate in [evaluateCloudflarePage, evaluateAftPage]) {
        expect(evaluate('  ').reason, PageDecisionReason.emptyDocument);
        final failure = evaluate(
          '<html>403 FORBIDDEN challenge_id cf_chl</html>',
        );
        expect(failure.accepted, isFalse);
        expect(failure.reason, PageDecisionReason.failureMarker);
        expect(failure.matchedMarker, '403 forbidden');
        // This intentionally characterizes the existing permissive rule.
        final unfamiliar = evaluate('<html>Please verify your age</html>');
        expect(unfamiliar.accepted, isTrue);
        expect(unfamiliar.reason, PageDecisionReason.noKnownMarkers);
      }
      expect(evaluateCloudflarePage('CF_CHL').matchedMarker, 'cf_chl');
      expect(
        evaluateCloudflarePage('CF_CHL').reason,
        PageDecisionReason.challengeMarker,
      );
      expect(
        evaluateAftPage('CHALLENGE HAS EXPIRED').reason,
        PageDecisionReason.failureMarker,
      );
      expect(
        evaluateAftPage('challenge_id').reason,
        PageDecisionReason.challengeMarker,
      );
    },
  );

  test(
    'event and decision use one page snapshot, including sensitive content',
    () async {
      final records = <ProtectionRecord>[];
      final details = <ProtectionSensitiveDetails>[];
      final session = ProtectionSession(
        host: 'example.com',
        type: 'cloudflare',
        onEvent: (record, {sensitive}) {
          records.add(record);
          if (sensitive != null) details.add(sensitive);
        },
      );
      var reads = 0;
      final check = session.beginCheck(CheckTrigger.pageFinished);
      final result = await inspectChallengePage(
        readSource: () async => ++reads == 1 ? 'cf_chl SECRET' : 'normal page',
        evaluate: evaluateCloudflarePage,
        diagnostics: check,
      );
      check.finish(CheckOutcome.pageRejected, alreadyCompleted: false);
      expect(reads, 1);
      final event = records
          .map((record) => record.event)
          .whereType<PageEvaluated>()
          .single;
      expect(event.evaluation, same(result));
      expect(event.evaluation.accepted, isFalse);
      expect(event.length, 'cf_chl SECRET'.length);
      expect(
        (details.single as ProtectionPageContents).contents,
        'cf_chl SECRET',
      );
      expect(records.map((record) => record.scope.checkId).toSet(), {check.id});
    },
  );

  test('inspection failure is distinct from an empty document', () async {
    final records = <ProtectionRecord>[];
    final session = ProtectionSession(
      host: 'example.com',
      type: 'cloudflare',
      onEvent: (record, {sensitive}) => records.add(record),
    );
    final check = session.beginCheck(CheckTrigger.timer);
    await expectLater(
      inspectChallengePage(
        readSource: () async => throw StateError('SECRET'),
        evaluate: evaluateCloudflarePage,
        diagnostics: check,
      ),
      throwsStateError,
    );
    expect(
      records.map((record) => record.event).whereType<PageEvaluated>(),
      isEmpty,
    );
    final error = records
        .map((record) => record.event)
        .whereType<ProtectionOperationFailed>()
        .single;
    expect(error.operation, ProtectionOperation.pageSource);
    expect(error.errorType, 'StateError');
    check.finish(CheckOutcome.failed, alreadyCompleted: false);
    final emptyCheck = session.beginCheck(CheckTrigger.manual);
    final empty = await inspectChallengePage(
      readSource: () async => '',
      evaluate: evaluateCloudflarePage,
      diagnostics: emptyCheck,
    );
    expect(empty.reason, PageDecisionReason.emptyDocument);
    emptyCheck.finish(CheckOutcome.pageRejected, alreadyCompleted: false);
  });

  test(
    'overlapping checks retain their scopes, triggers and active counts',
    () async {
      final records = <ProtectionRecord>[];
      final session = ProtectionSession(
        host: 'example.com',
        type: 'cloudflare',
        onEvent: (record, {sensitive}) => records.add(record),
      );
      final pending = Completer<String>();
      final timer = session.beginCheck(CheckTrigger.timer);
      final first = inspectChallengePage(
        readSource: () => pending.future,
        evaluate: evaluateCloudflarePage,
        diagnostics: timer,
      );
      final page = session.beginCheck(CheckTrigger.pageFinished);
      await inspectChallengePage(
        readSource: () async => 'normal page',
        evaluate: evaluateCloudflarePage,
        diagnostics: page,
      );
      page.finish(CheckOutcome.pageAccepted, alreadyCompleted: false);
      pending.complete('cf_chl');
      await first;
      timer.finish(CheckOutcome.pageRejected, alreadyCompleted: true);
      final manual = session.beginCheck(CheckTrigger.manual);
      manual.finish(CheckOutcome.alreadyCompleted, alreadyCompleted: true);
      final starts = records
          .map((record) => record.event)
          .whereType<CompletionCheckStarted>();
      expect(starts.map((event) => event.activeChecks), [1, 2, 1]);
      expect(starts.map((event) => event.trigger), [
        CheckTrigger.timer,
        CheckTrigger.pageFinished,
        CheckTrigger.manual,
      ]);
      expect(
        records
            .where((record) => record.event is CompletionCheckFinished)
            .map((record) => record.scope.checkId),
        [page.id, timer.id, manual.id],
      );
      expect(records.map((record) => record.scope.solverId).toSet(), {
        session.id,
      });
      expect(
        () => manual.finish(
          CheckOutcome.alreadyCompleted,
          alreadyCompleted: true,
        ),
        throwsStateError,
      );
    },
  );
}
