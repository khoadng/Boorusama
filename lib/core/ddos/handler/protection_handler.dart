// Package imports:
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
    void Function()? onSolved,
  }) : _orchestrator = orchestrator,
       _cookieJar = cookieJar,
       _contextProvider = contextProvider,
       _onSolved = onSolved;

  final ProtectionOrchestrator _orchestrator;
  final LazyAsync<CookieJar> _cookieJar;
  final ContextProvider _contextProvider;
  final void Function()? _onSolved;

  // Track retry attempts
  final Map<String, int> _retryAttempts = {};
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
  }) async {
    if (_disabled) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.disabled));
      return false;
    }

    try {
      final solved = await _orchestrator.handleResponse(
        response,
        attempt: attempt,
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
  }) async {
    if (_disabled) {
      attempt?.record(const RecoveryStopped(RecoveryStopReason.disabled));
      return false;
    }

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

  /// Resets retry attempts for a specific URI
  void resetRetryAttempts(Uri uri) {
    _retryAttempts.remove(uri.toString());
  }
}
