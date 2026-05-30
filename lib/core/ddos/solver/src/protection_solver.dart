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

      try {
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        if (userAgent != null) await controller.setUserAgent(userAgent);
        if (challengeCompletionValidator != null) {
          await controller.setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
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
    VoidCallback? onSuccess,
  }) async {
    if (completer.isCompleted) return true;

    try {
      final cookies = await _cookieRetriever.getCookies(uri.toString());

      if (_hasNewMatchingCookie(cookies, initialCookies)) {
        await jar.saveFromResponse(uri, cookies);
        if (!completer.isCompleted) completer.complete(true);
        onSuccess?.call();
        return true;
      }

      final validator = challengeCompletionValidator;
      if (validator == null || !await validator(controller)) return false;

      if (cookies.isNotEmpty) {
        await jar.saveFromResponse(uri, cookies);
      }
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
    'access denied',
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
    'x-verification-challenge',
    'wait for signal before clicking',
  ];
  if (challengeMarkers.any(lower.contains)) return false;

  return true;
}

Future<bool> _isAftSolved(WebViewController controller) async {
  final visibleText = await _getVisiblePageText(controller);

  return isAftSolvedPage(visibleText);
}

Future<String> _getVisiblePageText(WebViewController controller) async {
  try {
    final result = await controller.runJavaScriptReturningResult('''
(() => {
  const body = document.body;
  const root = document.documentElement;

  return (body && (body.innerText || body.textContent)) ||
    (root && (root.innerText || root.textContent)) ||
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
