// Package imports:
import 'package:html/parser.dart' as html;

enum PageDecisionReason {
  emptyDocument,
  failureMarker,
  blockedMarker,
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
  const PageEvaluation.blocked(String marker)
    : reason = PageDecisionReason.blockedMarker,
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

/// Judges the parsed document rather than its text: cleared pages can still
/// load Turnstile, hCaptcha or Cloudflare's bot detection scripts, while the
/// challenge page always defines `_cf_chl_opt` or loads its orchestrate script.
PageEvaluation evaluateCloudflarePage(String value) {
  if (value.trim().isEmpty) return const PageEvaluation.empty();

  final document = html.parse(value);
  final title = (document.querySelector('title')?.text ?? '')
      .trim()
      .toLowerCase();

  if (title.contains('403 forbidden')) {
    return const PageEvaluation.failure('title:403 forbidden');
  }

  const blockedTitles = ['access denied', 'attention required! | cloudflare'];
  for (final blocked in blockedTitles) {
    if (title.startsWith(blocked)) {
      return PageEvaluation.blocked('title:$blocked');
    }
  }
  const blockedSelectors = ['#cf-error-details', '.cf-error-title'];
  for (final selector in blockedSelectors) {
    if (document.querySelector(selector) != null) {
      return PageEvaluation.blocked(selector);
    }
  }

  for (final script in document.querySelectorAll('script')) {
    if (script.text.contains('_cf_chl_opt')) {
      return const PageEvaluation.challenge('script:_cf_chl_opt');
    }
    final src = script.attributes['src'] ?? '';
    if (src.contains('/cdn-cgi/challenge-platform/h/')) {
      return const PageEvaluation.challenge(
        'script:/cdn-cgi/challenge-platform/h/',
      );
    }
  }
  const challengeSelectors = [
    '#challenge-running',
    '#cf-challenge-running',
    '#challenge-spinner',
    '#challenge-error-text',
    '#cf-please-wait',
    '#trk_jschal_js',
    '#turnstile-wrapper',
  ];
  for (final selector in challengeSelectors) {
    if (document.querySelector(selector) != null) {
      return PageEvaluation.challenge(selector);
    }
  }
  if (title == 'just a moment...') {
    return const PageEvaluation.challenge('title:just a moment...');
  }

  return const PageEvaluation.noKnownMarkers();
}
