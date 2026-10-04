// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/ddos/solver/src/page_inspection.dart';
import 'package:boorusama/core/ddos/solver/src/protection_diagnostics.dart';

void main() {
  test('verification-site pages keep failure ahead of challenge markers', () {
    for (final evaluate in [evaluateCloudflarePage, evaluateAftPage]) {
      expect(evaluate('  ').reason, PageDecisionReason.emptyDocument);
    }
    final failure = evaluateAftPage('<html>403 FORBIDDEN challenge_id</html>');
    expect(failure.reason, PageDecisionReason.failureMarker);
    expect(failure.matchedMarker, '403 forbidden');
    expect(
      evaluateAftPage('challenge_id').reason,
      PageDecisionReason.challengeMarker,
    );
    expect(
      evaluateAftPage('<html>Please verify your age</html>').accepted,
      isTrue,
    );
  });

  const challengeScript =
      '<script>window._cf_chl_opt = {cType: "managed"};</script>';
  final cloudflarePages = [
    (
      name: 'challenge page restyled by the site',
      page:
          '<html><head><title>Example CAPTCHA</title></head><body><div class="captcha-box">$challengeScript</div></body></html>',
      reason: PageDecisionReason.challengeMarker,
    ),
    (
      name: 'translated challenge page',
      page: '<html><head><title>Doar un moment...</title><script src="/cdn-cgi/challenge-platform/h/b/orchestrate/chl_page/v1"></script></head></html>',
      reason: PageDecisionReason.challengeMarker,
    ),
    (
      name: 'challenge page still running',
      page: '<html><head><title>Just a moment...</title></head><body><div id="challenge-spinner"></div></body></html>',
      reason: PageDecisionReason.challengeMarker,
    ),
    (
      name: 'access denied page',
      page: '<html><head><title>Access denied | example.com used Cloudflare to restrict access</title></head><body><div id="cf-error-details"></div></body></html>',
      reason: PageDecisionReason.blockedMarker,
    ),
    (
      name: 'attention required page',
      page: '<html><head><title>Attention Required! | Cloudflare</title></head></html>',
      reason: PageDecisionReason.blockedMarker,
    ),
    (
      name: 'forbidden page',
      page: '<html><head><title>403 Forbidden</title></head><body>nginx</body></html>',
      reason: PageDecisionReason.failureMarker,
    ),
    (
      name: 'page that only configures hCaptcha',
      page: '<script>window.captchaCSSClass = "h-captcha";</script>',
      reason: PageDecisionReason.noKnownMarkers,
    ),
    (
      name: 'page with a reCAPTCHA form',
      page: '<form><div class="g-recaptcha"></div></form>',
      reason: PageDecisionReason.noKnownMarkers,
    ),
    (
      name: 'page with a Turnstile widget',
      page: '<div class="cf-turnstile"></div><script src="https://challenges.cloudflare.com/turnstile/v0/api.js"></script>',
      reason: PageDecisionReason.noKnownMarkers,
    ),
    (
      name: 'page with bot detection script',
      page: "<script>a.src='/cdn-cgi/challenge-platform/scripts/jsd/main.js';</script>",
      reason: PageDecisionReason.noKnownMarkers,
    ),
    (
      name: 'page that mentions the challenge in text',
      page: '<html><body><p>Just a moment... cf_chl _cf_chl_opt</p></body></html>',
      reason: PageDecisionReason.noKnownMarkers,
    ),
  ];
  for (final c in cloudflarePages) {
    test('cloudflare ${c.name} is judged ${c.reason.name}', () {
      expect(evaluateCloudflarePage(c.page).reason, c.reason);
    });
  }

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
        readSource: () async => ++reads == 1
            ? '<script>_cf_chl_opt</script> SECRET'
            : 'normal page',
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
      expect(event.length, '<script>_cf_chl_opt</script> SECRET'.length);
      expect(
        (details.single as ProtectionPageContents).contents,
        '<script>_cf_chl_opt</script> SECRET',
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
      pending.complete('<script>_cf_chl_opt</script>');
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
