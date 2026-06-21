// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'protection_overlay.dart';

abstract class ProtectionSolver {
  /// The type of protection this solver handles
  String get protectionType;

  /// Whether this solver is currently busy solving a challenge
  bool get isSolving;

  /// Solves the protection challenge and returns when done
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  });

  /// Cancels an ongoing solving process if possible
  Future<void> cancel();
}

typedef ContextProvider = BuildContext? Function();
typedef ChallengeCompletionValidator =
    Future<bool> Function(WebViewController controller);

const _ddosSolverLogSnippetLength = 2000;

abstract class CookieRetriever {
  Future<List<Cookie>> getCookies(String url);
}

class WebviewCookieRetriever implements CookieRetriever {
  final _cookieManager = WebviewCookieManager();

  @override
  Future<List<Cookie>> getCookies(String url) => _cookieManager.getCookies(url);
}

class RawSolver implements ProtectionSolver {
  RawSolver({
    required this.protectionType,
    required this.protectionTitle,
    required this.autoCookieValidator,
    required this.contextProvider,
    required this.cookieJar,
    this.challengeCompletionValidator,
    CookieRetriever? cookieRetriever,
  }) : _cookieRetriever = cookieRetriever ?? WebviewCookieRetriever();

  @override
  final String protectionType;
  final String protectionTitle;
  final bool Function(Cookie) autoCookieValidator;
  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final ChallengeCompletionValidator? challengeCompletionValidator;

  final CookieRetriever _cookieRetriever;
  var _solving = false;

  @override
  bool get isSolving => _solving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) async {
    if (_solving) return false;
    _solving = true;

    final completer = Completer<bool>();
    final context = contextProvider();

    if (context == null) {
      _solving = false;
      completer.complete(false);
      return completer.future;
    }

    if (!context.mounted) {
      _solving = false;
      completer.complete(false);
      return completer.future;
    }

    final navigator = Navigator.of(context);

    try {
      final jar = await cookieJar();
      final controller = WebViewController();
      final initialCookies = await _getMatchingCookieValues(uri);
      var hasFinishedPageLoad = false;
      debugPrint(
        '[DDOS:$protectionType] start uri=$uri '
        'userAgent=${userAgent ?? '<default>'} '
        'initialMatchingCookies=${initialCookies.keys.join(',')}',
      );

      try {
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        if (userAgent != null) await controller.setUserAgent(userAgent);
        if (challengeCompletionValidator != null) {
          await controller.setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                hasFinishedPageLoad = true;
                debugPrint('[DDOS:$protectionType] page finished url=$url');
                unawaited(
                  _completeIfSolved(
                    uri: uri,
                    jar: jar,
                    controller: controller,
                    completer: completer,
                    initialCookies: initialCookies,
                    onSuccess: () {
                      if (navigator.canPop()) navigator.pop(true);
                    },
                  ),
                );
              },
            ),
          );
        }
      } catch (_) {
        // Keep showing the solver; the page may still load with defaults.
      }
      unawaited(controller.loadRequest(uri).catchError((_) {}));

      if (!context.mounted) {
        _solving = false;
        completer.complete(false);
        return completer.future;
      }

      _monitorCompletion(
        uri: uri,
        jar: jar,
        controller: controller,
        completer: completer,
        initialCookies: initialCookies,
        allowPageValidation: () => hasFinishedPageLoad,
        onSuccess: () {
          if (navigator.canPop()) navigator.pop(true);
        },
      );

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        routeSettings: const RouteSettings(name: 'challenge_solver'),
        builder: (dialogContext) {
          final dialogNavigator = Navigator.of(dialogContext);

          return Dialog.fullscreen(
            child: ProtectionOverlay(
              url: uri.toString(),
              controller: controller,
              onCancel: () => dialogNavigator.pop(false),
              onSolved: () async {
                final solved = await _completeIfSolved(
                  uri: uri,
                  jar: jar,
                  controller: controller,
                  completer: completer,
                  initialCookies: initialCookies,
                );

                if (solved) {
                  dialogNavigator.pop(true);
                }
              },
            ),
          );
        },
      );

      if (!completer.isCompleted) {
        completer.complete(result ?? false);
      }
    } catch (e) {
      completer.complete(false);
    } finally {
      _solving = false;
      // Force completer to resolve if somehow still pending
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    return completer.future.whenComplete(() {
      _solving = false;
    });
  }

  void _monitorCompletion({
    required Uri uri,
    required CookieJar jar,
    required WebViewController controller,
    required Completer<bool> completer,
    required Map<String, String> initialCookies,
    bool Function()? allowPageValidation,
    required VoidCallback onSuccess,
  }) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_solving || completer.isCompleted) {
        timer.cancel();
        return;
      }

      final solved = await _completeIfSolved(
        uri: uri,
        jar: jar,
        controller: controller,
        completer: completer,
        initialCookies: initialCookies,
        allowPageValidation: allowPageValidation?.call() ?? true,
        onSuccess: onSuccess,
      );

      if (solved) timer.cancel();
    });
  }

  Future<bool> _completeIfSolved({
    required Uri uri,
    required CookieJar jar,
    required WebViewController controller,
    required Completer<bool> completer,
    required Map<String, String> initialCookies,
    bool allowPageValidation = true,
    VoidCallback? onSuccess,
  }) async {
    if (completer.isCompleted) return true;

    try {
      final cookies = await _cookieRetriever.getCookies(uri.toString());
      final currentUrl = await _safeCurrentUrl(controller);
      debugPrint(
        '[DDOS:$protectionType] check uri=$uri '
        'currentUrl=${currentUrl ?? '<unknown>'} '
        'cookies=${_formatCookies(cookies)}',
      );

      if (_hasNewMatchingCookie(cookies, initialCookies)) {
        await jar.saveFromResponse(uri, cookies);
        debugPrint('[DDOS:$protectionType] complete via matching cookie');
        if (!completer.isCompleted) completer.complete(true);
        onSuccess?.call();
        return true;
      }

      final validator = challengeCompletionValidator;
      if (validator == null) {
        debugPrint('[DDOS:$protectionType] pending cookie-only solver');
        return false;
      }

      if (!allowPageValidation) {
        debugPrint(
          '[DDOS:$protectionType] pending page validator until page finished',
        );
        return false;
      }

      final solvedByPage = await validator(controller);
      debugPrint('[DDOS:$protectionType] page validator=$solvedByPage');

      if (!solvedByPage) {
        final pageSource = await _getPageSource(controller);
        debugPrint(
          '[DDOS:$protectionType] pending page='
          '${_formatPageSnippet(pageSource)}',
        );
        return false;
      }

      if (cookies.isNotEmpty) {
        await jar.saveFromResponse(uri, cookies);
      }
      debugPrint('[DDOS:$protectionType] complete via page content');
      if (!completer.isCompleted) completer.complete(true);
      onSuccess?.call();
      return true;
    } catch (e) {
      debugPrint('Error checking challenge completion: $e');
      return false;
    }
  }

  Future<Map<String, String>> _getMatchingCookieValues(Uri uri) async {
    try {
      final cookies = await _cookieRetriever.getCookies(uri.toString());

      return {
        for (final cookie in cookies)
          if (autoCookieValidator(cookie)) cookie.name: cookie.value,
      };
    } catch (_) {
      return {};
    }
  }

  bool _hasNewMatchingCookie(
    List<Cookie> cookies,
    Map<String, String> initialCookies,
  ) {
    return cookies.any((cookie) {
      if (!autoCookieValidator(cookie)) return false;

      return initialCookies[cookie.name] != cookie.value;
    });
  }

  @override
  Future<void> cancel() async => _solving = false;
}

Future<bool> waitForAutoSolve({
  required Uri uri,
  required CookieJar jar,
  required CookieRetriever cookieRetriever,
  required bool Function(Cookie) autoCookieValidator,
  required bool Function() isCancelled,
  int maxAttempts = 5,
  Duration pollInterval = const Duration(seconds: 1),
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await Future.delayed(pollInterval);
    if (isCancelled()) return false;

    try {
      final cookies = await cookieRetriever.getCookies(uri.toString());
      if (cookies.any(autoCookieValidator)) {
        await jar.saveFromResponse(uri, cookies);
        return true;
      }
    } catch (_) {}
  }
  return false;
}

class CloudflareSolver implements ProtectionSolver {
  CloudflareSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'cloudflare',
    protectionTitle: 'Solving Cloudflare Challenge',
    autoCookieValidator: (cookie) =>
        cookie.name.toLowerCase() == 'cf_clearance',
    challengeCompletionValidator: _isCloudflareSolved,
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

class AftSolver implements ProtectionSolver {
  AftSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'aft',
    protectionTitle: 'Solving verification challenge',
    autoCookieValidator: (cookie) {
      final cookieName = cookie.name.toLowerCase();

      return cookieName.contains('challenge') ||
          cookieName.contains('verification') ||
          cookieName.contains('aft');
    },
    challengeCompletionValidator: _isAftSolved,
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

bool isAftSolvedPage(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;

  final lower = normalized.toLowerCase();
  const failureMarkers = [
    '403 forbidden',
    'failure!',
    'challenge has expired',
    'reloading the page to try again',
  ];
  if (failureMarkers.any(lower.contains)) return false;

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
  if (challengeMarkers.any(lower.contains)) return false;

  return true;
}

Future<bool> _isAftSolved(WebViewController controller) async {
  final pageSource = await _getPageSource(controller);

  return isAftSolvedPage(pageSource);
}

bool isCloudflareSolvedPage(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return false;

  final lower = normalized.toLowerCase();
  const failureMarkers = [
    '403 forbidden',
  ];
  if (failureMarkers.any(lower.contains)) return false;

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
  if (challengeMarkers.any(lower.contains)) return false;

  return true;
}

Future<bool> _isCloudflareSolved(WebViewController controller) async {
  final pageSource = await _getPageSource(controller);

  return isCloudflareSolvedPage(pageSource);
}

Future<String> _getPageSource(WebViewController controller) async {
  try {
    final result = await controller.runJavaScriptReturningResult('''
(() => {
  const body = document.body;
  const root = document.documentElement;

  return (root && root.outerHTML) ||
    (body && (body.innerText || body.textContent)) ||
    '';
})()
''');

    return _javaScriptResultAsString(result);
  } catch (_) {
    return '';
  }
}

String _javaScriptResultAsString(Object? result) {
  if (result == null) return '';
  if (result is! String) return result.toString();

  try {
    final decoded = jsonDecode(result);
    return decoded is String ? decoded : result;
  } catch (_) {
    return result;
  }
}

Future<String?> _safeCurrentUrl(WebViewController controller) async {
  try {
    return controller.currentUrl();
  } catch (_) {
    return null;
  }
}

String _formatCookies(List<Cookie> cookies) {
  if (cookies.isEmpty) return '[]';

  return cookies
      .map(
        (cookie) =>
            '{name:${cookie.name}, domain:${cookie.domain}, '
            'path:${cookie.path}, expires:${cookie.expires}, '
            'secure:${cookie.secure}, httpOnly:${cookie.httpOnly}, '
            'valueLength:${cookie.value.length}}',
      )
      .join(', ');
}

String _formatPageSnippet(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= _ddosSolverLogSnippetLength) return normalized;

  return '${normalized.substring(0, _ddosSolverLogSnippetLength)}...';
}

class CaptchaAccessDeniedSolver implements ProtectionSolver {
  CaptchaAccessDeniedSolver({
    required this.contextProvider,
    required this.cookieJar,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;

  late final _solver = RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    protectionType: 'captcha_access_denied',
    protectionTitle: 'Solving CAPTCHA',
    autoCookieValidator: (cookie) {
      final cookieName = cookie.name.toLowerCase();

      return cookieName == 'cf_clearance' || cookieName.contains('clearance');
    },
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}
