enum PageDecisionReason {
  emptyDocument,
  failureMarker,
  challengeMarker,
  noKnownMarkers,
}

/// The acceptance rule and its explanation are one value from one snapshot.
class PageEvaluation {
  const PageEvaluation.empty()
    : reason = PageDecisionReason.emptyDocument,
      matchedMarker = null;
  const PageEvaluation.failure(String marker)
    : reason = PageDecisionReason.failureMarker,
      matchedMarker = marker;
  const PageEvaluation.challenge(String marker)
    : reason = PageDecisionReason.challengeMarker,
      matchedMarker = marker;
  const PageEvaluation.noKnownMarkers()
    : reason = PageDecisionReason.noKnownMarkers,
      matchedMarker = null;

  final PageDecisionReason reason;
  final String? matchedMarker;
  bool get accepted => reason == PageDecisionReason.noKnownMarkers;
}

typedef PageEvaluator = PageEvaluation Function(String source);

PageEvaluation evaluateAftPage(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return const PageEvaluation.empty();

  final lower = normalized.toLowerCase();
  const failureMarkers = [
    '403 forbidden',
    'failure!',
    'challenge has expired',
    'reloading the page to try again',
  ];
  for (final marker in failureMarkers) {
    if (lower.contains(marker)) return PageEvaluation.failure(marker);
  }

  const challengeMarkers = [
    'challenge_id',
    'challenge_generated',
    'challenge-checkbox',
    'challenge-container',
    'challenge-prompt',
    'checkbox-status',
    'x-verification-challenge',
    'powseed',
    'sendanswer',
    'i am not a robot',
    'it is now okay to proceed',
    'wait for signal before clicking',
  ];
  for (final marker in challengeMarkers) {
    if (lower.contains(marker)) return PageEvaluation.challenge(marker);
  }

  return const PageEvaluation.noKnownMarkers();
}

PageEvaluation evaluateCloudflarePage(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return const PageEvaluation.empty();

  final lower = normalized.toLowerCase();
  const failureMarkers = [
    '403 forbidden',
  ];
  for (final marker in failureMarkers) {
    if (lower.contains(marker)) return PageEvaluation.failure(marker);
  }

  const challengeMarkers = [
    'cf_chl',
    'cf-ray',
    'cf-turnstile',
    'cf-mitigated',
    'challenges.cloudflare.com',
    '/cdn-cgi/challenge-platform',
    'challenge-platform',
    'challenge-error-text',
    'enable javascript and cookies',
    'just a moment',
    'checking if the site connection is secure',
    'captcha-box',
    'h-captcha',
    'g-recaptcha',
  ];
  for (final marker in challengeMarkers) {
    if (lower.contains(marker)) return PageEvaluation.challenge(marker);
  }

  return const PageEvaluation.noKnownMarkers();
}
