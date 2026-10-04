// Package imports:
import 'package:clock/clock.dart';
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../solver/types.dart';

class HttpProtectionHandler {
  HttpProtectionHandler({
    required ProtectionOrchestrator orchestrator,
    required ContextProvider contextProvider,
    required LazyAsync<CookieJar> cookieJar,
    this.maxRetries = 3,
    this.onEvent,
    Clock clock = const Clock(),
    void Function()? onSolved,
  }) : _orchestrator = orchestrator,
       _cookieJar = cookieJar,
       _clock = clock,
       _contextProvider = contextProvider,
       _onSolved = onSolved;

  final ProtectionOrchestrator _orchestrator;
  final LazyAsync<CookieJar> _cookieJar;
  final ContextProvider _contextProvider;
  final Clock _clock;
  final void Function()? _onSolved;

  // Track retry attempts
  final Map<String, int> _retryAttempts = {};

  // Avoid immediate challenge loops after a failed handoff, while allowing a
  // later request to recover without requiring a successful request first.
  final Map<String, DateTime> _blockedAfterSolve = {};
  static const _blockedAfterSolveCooldown = Duration(seconds: 30);
  final int maxRetries;
  final ProtectionEventSink? onEvent;

  ProtectionAttempt beginAttempt(Uri uri, ProtectionSource source) {
    final attempt = ProtectionAttempt(
      source: source,
      host: uri.host,
      onEvent: onEvent,
    );
    attempt.record(const AttemptStarted());
    return attempt;
  }

  var _disabled = false;

  bool get isDisabled => _disabled;
  void disable() => _disabled = true;
  void enable() => _disabled = false;

  /// Prepares request headers with cookie and user agent information
  Future<Map<String, String>> prepareRequestHeaders(
    Uri uri,
    Map<String, String> existingHeaders, {
    ProtectionAttempt? attempt,
  }) async {
    if (_disabled) {
      attempt?.record(
        const HeaderPreparationSkipped(HeaderPreparationSkipReason.disabled),
      );
      return existingHeaders;
    }

    try {
      final cookies = await (await _cookieJar()).loadForRequest(uri);
      final headers = Map<String, String>.from(existingHeaders);

      attempt?.record(
        CookieLookupCompleted(CookieStore.requestJar, cookies.length),
      );
      if (cookies.isNotEmpty) {
        final userAgent = await _orchestrator.getUserAgent();

        if (userAgent == null) {
          attempt?.record(
            const HeaderPreparationSkipped(
              HeaderPreparationSkipReason.userAgentUnavailable,
            ),
          );
          return existingHeaders;
        }

        final existingCookie = _headerValue(headers, 'cookie') ?? '';
        final mergedCookie = CookieUtils.mergeCookieHeaders(
          existingCookie,
          cookies.cookieString,
        );
        _setHeader(headers, 'cookie', mergedCookie);
        _setHeader(headers, 'user-agent', userAgent);
      }

      final clearance = attempt?.clearanceCookie;
      if (clearance != null) {
        _setHeader(
          headers,
          'cookie',
          CookieUtils.mergeCookieHeaders(
            _headerValue(headers, 'cookie') ?? '',
            '${clearance.name}=${clearance.value}',
          ),
        );
      }

      attempt?.observeHeaders(headers);
      return headers;
    } catch (e) {
      attempt?.record(
        ProtectionOperationFailed(
          ProtectionOperation.prepareHeaders,
          e.runtimeType.toString(),
        ),
      );
      return existingHeaders;
    }
  }

  static String? _headerValue(Map<String, String> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value;
    }
    return null;
  }

  static void _setHeader(
    Map<String, String> headers,
    String name,
    String value,
  ) {
    headers.removeWhere((key, _) => key.toLowerCase() == name);
    headers[name] = value;
  }

  /// Handles HTTP response and returns true if a protection was detected and handled
  Future<bool> handleResponse(
    HttpResponse response, {
    ProtectionAttempt? attempt,
    Uri? challengeUri,
  }) async {
    if (_disabled) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.disabled));
      return false;
    }

    try {
      final solved = await _orchestrator.handleResponse(
        response,
        attempt: attempt,
        challengeUri: challengeUri,
      );
      if (solved) _onSolved?.call();

      return solved;
    } catch (e) {
      attempt?.record(
        ProtectionOperationFailed(
          ProtectionOperation.handler,
          e.runtimeType.toString(),
        ),
      );
      return false;
    }
  }

  /// Handles HTTP error and returns true if a protection was detected and solved
  Future<bool> handleError(
    HttpError error, {
    ProtectionAttempt? attempt,
    Uri? challengeUri,
  }) async {
    if (_disabled) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.disabled));
      return false;
    }

    final blockedUntil = _blockedAfterSolve[error.requestUri.origin];
    if (blockedUntil != null && _clock.now().isBefore(blockedUntil)) {
      attempt?.record(
        const RecoveryStopped(RecoveryStopReason.blockedAfterSolve),
      );
      return false;
    }
    _blockedAfterSolve.remove(error.requestUri.origin);

    final uriString = error.requestUri.toString();
    final retryCount = _retryAttempts[uriString] ?? 0;

    attempt?.record(RetryBudgetObserved(retryCount, maxRetries));
    if (retryCount >= maxRetries) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.retryLimit));
      _retryAttempts.remove(uriString);
      return false;
    }

    try {
      final context = _contextProvider();

      if (context == null) {
        attempt?.record(const RecoveryStopped(RecoveryStopReason.noContext));
        return false;
      }

      final solved = await _orchestrator.handleError(
        context,
        error,
        attempt: attempt,
        challengeUri: challengeUri,
      );

      if (solved) {
        _onSolved?.call();
        _retryAttempts[uriString] = retryCount + 1;
        return true;
      }
    } catch (e) {
      attempt?.record(
        ProtectionOperationFailed(
          ProtectionOperation.handler,
          e.runtimeType.toString(),
        ),
      );
      // Fall through to return false
    }

    return false;
  }

  /// Records the outcome of the retry sent after a reported solve. A retry
  /// that is still blocked briefly stops further solving for its origin.
  void observeRetryError(HttpError error, {ProtectionAttempt? attempt}) {
    if (!_orchestrator.detectsErrorProtection(error)) return;
    attempt?.record(const RetryStillBlocked());
    _blockedAfterSolve[error.requestUri.origin] = _clock.now().add(
      _blockedAfterSolveCooldown,
    );
    resetRetryAttempts(error.requestUri);
  }

  void observeSuccess(Uri uri) => _blockedAfterSolve.remove(uri.origin);

  bool selectAlternativeClearance(
    HttpError error,
    ProtectionAttempt attempt,
  ) =>
      !_disabled &&
      _orchestrator.detectsErrorProtection(error) &&
      attempt.selectNextClearanceCookie();

  /// Persist the browser cookie that the real HTTP transport accepted. WebKit
  /// may return multiple partitioned cookies with the same name/domain/path,
  /// so a successful browser page alone cannot select one for the request jar.
  Future<void> confirmRetry(Uri uri, ProtectionAttempt attempt) async {
    final clearance = attempt.clearanceCookie;
    if (clearance == null) return;
    try {
      final jar = await _cookieJar();
      final stored = await jar.loadForRequest(uri);
      await jar.saveFromResponse(uri, [
        for (final cookie in stored)
          if (cookie.name == clearance.name && cookie.value != clearance.value)
            Cookie(cookie.name, '')
              ..domain = cookie.domain
              ..path = cookie.path
              ..maxAge = 0,
        clearance,
      ]);
      _onSolved?.call();
    } catch (error) {
      attempt.record(
        ProtectionOperationFailed(
          ProtectionOperation.handler,
          error.runtimeType.toString(),
        ),
      );
    }
  }

  /// Resets retry attempts for a specific URI
  void resetRetryAttempts(Uri uri) {
    _retryAttempts.remove(uri.toString());
  }
}
