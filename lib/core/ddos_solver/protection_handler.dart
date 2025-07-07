// Package imports:
import 'package:cookie_jar/cookie_jar.dart';

// Project imports:
import 'protection_orchestrator.dart';
import 'protection_solver.dart';
import 'types.dart';

class HttpProtectionHandler {
  HttpProtectionHandler({
    required ProtectionOrchestrator orchestrator,
    required ContextProvider contextProvider,
    required CookieJar cookieJar,
    this.maxRetries = 3,
  }) : _orchestrator = orchestrator,
       _cookieJar = cookieJar,
       _contextProvider = contextProvider;

  final ProtectionOrchestrator _orchestrator;
  final CookieJar _cookieJar;
  final ContextProvider _contextProvider;

  // Track retry attempts
  final Map<String, int> _retryAttempts = {};
  final int maxRetries;
  bool _disabled = false;

  bool get isDisabled => _disabled;
  void disable() => _disabled = true;
  void enable() => _disabled = false;

  /// Prepares request headers with cookie and user agent information
  Future<Map<String, String>> prepareRequestHeaders(
    Uri uri,
    Map<String, String> existingHeaders,
  ) async {
    if (_disabled) return existingHeaders;

    try {
      final cookies = await _cookieJar.loadForRequest(uri);
      final headers = Map<String, String>.from(existingHeaders);

      if (cookies.isNotEmpty) {
        final userAgent = await _orchestrator.getUserAgent();

        if (userAgent == null) {
          _disabled = true;
          return existingHeaders;
        }

        headers['cookie'] = cookies
            .map((c) => '${c.name}=${c.value}')
            .join('; ');
        headers['user-agent'] = userAgent;
      }

      return headers;
    } catch (e) {
      _disabled = true;
      return existingHeaders;
    }
  }

  /// Handles HTTP response and returns true if a protection was detected and handled
  Future<bool> handleResponse(HttpResponse response) async {
    if (_disabled) return false;

    try {
      return await _orchestrator.handleResponse(response);
    } catch (e) {
      return false;
    }
  }

  /// Handles HTTP error and returns true if a protection was detected and solved
  Future<bool> handleError(HttpError error) async {
    if (_disabled) return false;

    final uriString = error.requestUri.toString();
    final retryCount = _retryAttempts[uriString] ?? 0;

    if (retryCount >= maxRetries) {
      _retryAttempts.remove(uriString);
      return false;
    }

    try {
      final context = _contextProvider();

      if (context == null) {
        return false;
      }

      final solved = await _orchestrator.handleError(context, error);

      if (solved) {
        _retryAttempts[uriString] = retryCount + 1;
        return true;
      }
    } catch (e) {
      // Fall through to return false
    }

    return false;
  }

  /// Resets retry attempts for a specific URI
  void resetRetryAttempts(Uri uri) {
    _retryAttempts.remove(uri.toString());
  }
}
