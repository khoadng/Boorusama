// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:kurumi/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'page_inspection.dart';
import 'protection_diagnostics.dart';
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
    ProtectionSession? diagnostics,
  });

  /// Cancels an ongoing solving process if possible
  Future<void> cancel();
}

typedef ContextProvider = BuildContext? Function();

abstract class CookieRetriever {
  Future<List<Cookie>> getCookies(String url);
}

class WebviewCookieRetriever implements CookieRetriever {
  final _cookieManager = WebViewCookieManager();

  @override
  Future<List<Cookie>> getCookies(String url) async {
    final cookies = await _cookieManager.getCookies(domain: Uri.parse(url));

    return [
      for (final cookie in cookies)
        Cookie(cookie.name, cookie.value)
          ..domain = cookie.domain
          ..path = cookie.path,
    ];
  }
}

class RawSolver implements ProtectionSolver {
  RawSolver({
    required this.protectionType,
    required this.protectionTitle,
    required this.autoCookieValidator,
    required this.contextProvider,
    required this.cookieJar,
    this.pageEvaluator,
    CookieRetriever? cookieRetriever,
  }) : _cookieRetriever = cookieRetriever ?? WebviewCookieRetriever();

  @override
  final String protectionType;
  final String protectionTitle;
  final bool Function(Cookie) autoCookieValidator;
  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final PageEvaluator? pageEvaluator;
  final CookieRetriever _cookieRetriever;
  var _solving = false;

  @override
  bool get isSolving => _solving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) async {
    final session =
        diagnostics ?? ProtectionSession(host: uri.host, type: protectionType);
    if (_solving) {
      session.record(const RecoveryStopped(RecoveryStopReason.busy));
      return false;
    }
    _solving = true;
    final completer = Completer<bool>();
    session.record(
      const SolverStarted(),
      sensitive: ProtectionRequestDetails(uri, userAgent: userAgent),
    );
    final context = contextProvider();
    if (context == null) {
      session.record(const RecoveryStopped(RecoveryStopReason.noContext));
      _solving = false;
      completer.complete(false);
      return completer.future;
    }
    if (!context.mounted) {
      session.record(
        const RecoveryStopped(RecoveryStopReason.unmountedContext),
      );
      _solving = false;
      completer.complete(false);
      return completer.future;
    }
    final navigator = Navigator.of(context);
    ModalRoute<dynamic>? dialogRoute;
    void recordClose(
      ProtectionTrace trace,
      DialogCloseTrigger trigger,
      NavigatorState target,
      bool canPop,
    ) {
      trace.record(
        DialogCloseRequested(
          trigger: trigger,
          navigatorId: identityHashCode(target),
          routeId: dialogRoute == null ? null : identityHashCode(dialogRoute),
          routeIsCurrent: dialogRoute?.isCurrent,
          canPop: canPop,
          alreadyCompleted: completer.isCompleted,
        ),
      );
    }

    void autoClose(ProtectionCheck check, DialogCloseTrigger trigger) {
      final canPop = navigator.canPop();
      recordClose(check, trigger, navigator, canPop);
      if (canPop) navigator.pop(true);
    }

    try {
      final jar = await cookieJar();
      final controller = WebViewController();
      final initialCookies = await _getMatchingCookieValues(uri, session);
      session.record(
        CookieLookupCompleted(
          CookieStore.webView,
          initialCookies.length,
          matchingOnly: true,
        ),
      );
      var hasFinishedPageLoad = false;
      try {
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        if (userAgent != null) await controller.setUserAgent(userAgent);
        if (pageEvaluator != null) {
          await controller.setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) => session.record(
                PageNavigationObserved(
                  PageNavigationPhase.started,
                  Uri.tryParse(url)?.host,
                ),
                sensitive: ProtectionNavigationDetails(url),
              ),
              onWebResourceError: (error) => session.record(
                WebResourceFailed(
                  code: error.errorCode,
                  type: error.errorType?.name,
                  mainFrame: error.isForMainFrame,
                ),
              ),
              onPageFinished: (url) {
                hasFinishedPageLoad = true;
                session.record(
                  PageNavigationObserved(
                    PageNavigationPhase.finished,
                    Uri.tryParse(url)?.host,
                  ),
                  sensitive: ProtectionNavigationDetails(url),
                );
                final check = session.beginCheck(CheckTrigger.pageFinished);
                unawaited(
                  _completeIfSolved(
                    check: check,
                    uri: uri,
                    jar: jar,
                    controller: controller,
                    completer: completer,
                    initialCookies: initialCookies,
                    onCredentials: (cookies) =>
                        session.observeCompletion(cookies, userAgent),
                    onSuccess: () =>
                        autoClose(check, DialogCloseTrigger.pageFinished),
                  ),
                );
              },
            ),
          );
        }
      } catch (error) {
        session.record(
          ProtectionOperationFailed(
            ProtectionOperation.webViewSetup,
            error.runtimeType.toString(),
          ),
        );
        // Preserve the existing policy: setup failures do not dismiss the solver.
      }
      unawaited(
        controller.loadRequest(uri).catchError((Object error) {
          session.record(
            ProtectionOperationFailed(
              ProtectionOperation.loadRequest,
              error.runtimeType.toString(),
            ),
          );
        }),
      );
      if (!context.mounted) {
        session.record(
          const RecoveryStopped(RecoveryStopReason.unmountedContext),
        );
        _solving = false;
        completer.complete(false);
        return await completer.future;
      }
      _monitorCompletion(
        session: session,
        uri: uri,
        jar: jar,
        controller: controller,
        completer: completer,
        initialCookies: initialCookies,
        onCredentials: (cookies) =>
            session.observeCompletion(cookies, userAgent),
        allowPageValidation: () => hasFinishedPageLoad,
        onSuccess: (check) => autoClose(check, DialogCloseTrigger.timer),
      );
      session.record(const DialogOpening());
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        routeSettings: const RouteSettings(name: 'challenge_solver'),
        builder: (dialogContext) {
          final dialogNavigator = Navigator.of(dialogContext);
          final route = ModalRoute.of(dialogContext);
          if (!identical(route, dialogRoute)) {
            dialogRoute = route;
            session.record(
              DialogPresented(route == null ? null : identityHashCode(route)),
            );
          }
          return Dialog.fullscreen(
            child: ProtectionOverlay(
              url: uri.toString(),
              controller: controller,
              onCancel: () {
                recordClose(
                  session,
                  DialogCloseTrigger.cancel,
                  dialogNavigator,
                  dialogNavigator.canPop(),
                );
                dialogNavigator.pop(false);
              },
              onSolved: () async {
                final check = session.beginCheck(CheckTrigger.manual);
                final solved = await _completeIfSolved(
                  check: check,
                  uri: uri,
                  jar: jar,
                  controller: controller,
                  completer: completer,
                  initialCookies: initialCookies,
                  onCredentials: (cookies) =>
                      session.observeCompletion(cookies, userAgent),
                );
                if (solved) {
                  recordClose(
                    check,
                    DialogCloseTrigger.manual,
                    dialogNavigator,
                    dialogNavigator.canPop(),
                  );
                  dialogNavigator.pop(true);
                }
              },
            ),
          );
        },
      );
      session.record(DialogClosed(result));
      if (!completer.isCompleted) completer.complete(result ?? false);
    } catch (error) {
      session.record(
        ProtectionOperationFailed(
          ProtectionOperation.solver,
          error.runtimeType.toString(),
        ),
      );
      completer.complete(false);
    } finally {
      _solving = false;
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future.whenComplete(() {
      _solving = false;
    });
  }

  void _monitorCompletion({
    required ProtectionSession session,
    required Uri uri,
    required CookieJar jar,
    required WebViewController controller,
    required Completer<bool> completer,
    required Map<String, String> initialCookies,
    required void Function(Map<String, String>) onCredentials,
    bool Function()? allowPageValidation,
    required void Function(ProtectionCheck) onSuccess,
  }) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_solving || completer.isCompleted) {
        timer.cancel();
        return;
      }
      final check = session.beginCheck(CheckTrigger.timer);
      final solved = await _completeIfSolved(
        check: check,
        uri: uri,
        jar: jar,
        controller: controller,
        completer: completer,
        initialCookies: initialCookies,
        onCredentials: onCredentials,
        allowPageValidation: allowPageValidation?.call() ?? true,
        onSuccess: () => onSuccess(check),
      );
      if (solved) timer.cancel();
    });
  }

  Future<bool> _completeIfSolved({
    required ProtectionCheck check,
    required Uri uri,
    required CookieJar jar,
    required WebViewController controller,
    required Completer<bool> completer,
    required Map<String, String> initialCookies,
    required void Function(Map<String, String>) onCredentials,
    bool allowPageValidation = true,
    VoidCallback? onSuccess,
  }) async {
    var outcome = CheckOutcome.failed;
    var alreadyCompleted = completer.isCompleted;
    try {
      if (completer.isCompleted) {
        outcome = CheckOutcome.alreadyCompleted;
        return true;
      }
      final cookies = await _cookieRetriever.getCookies(uri.toString());
      final currentUrl = await _safeCurrentUrl(controller, check);
      final changed = _hasNewMatchingCookie(cookies, initialCookies);
      check.record(
        CookiesObserved(
          count: cookies.length,
          matching: cookies.where(autoCookieValidator).length,
          changed: changed,
          currentHost: Uri.tryParse(currentUrl ?? '')?.host,
        ),
      );
      if (changed) {
        await jar.saveFromResponse(uri, cookies);
        alreadyCompleted = completer.isCompleted;
        onCredentials({
          for (final cookie in cookies)
            if (autoCookieValidator(cookie)) cookie.name: cookie.value,
        });
        if (!completer.isCompleted) completer.complete(true);
        outcome = CheckOutcome.changedCookie;
        onSuccess?.call();
        return true;
      }
      final evaluator = pageEvaluator;
      if (evaluator == null) {
        outcome = CheckOutcome.cookieOnly;
        return false;
      }
      if (!allowPageValidation) {
        outcome = CheckOutcome.pageNotFinished;
        return false;
      }
      final evaluation = await inspectChallengePage(
        readSource: () => _getPageSource(controller),
        evaluate: evaluator,
        diagnostics: check,
      );
      if (!evaluation.accepted) {
        outcome = CheckOutcome.pageRejected;
        return false;
      }
      if (cookies.isNotEmpty) await jar.saveFromResponse(uri, cookies);
      onCredentials({
        for (final cookie in cookies)
          if (autoCookieValidator(cookie)) cookie.name: cookie.value,
      });
      alreadyCompleted = completer.isCompleted;
      if (!completer.isCompleted) completer.complete(true);
      outcome = CheckOutcome.pageAccepted;
      onSuccess?.call();
      return true;
    } catch (error) {
      outcome = CheckOutcome.failed;
      check.record(
        ProtectionOperationFailed(
          ProtectionOperation.completionCheck,
          error.runtimeType.toString(),
        ),
      );
      return false;
    } finally {
      if (outcome != CheckOutcome.changedCookie &&
          outcome != CheckOutcome.pageAccepted) {
        alreadyCompleted = completer.isCompleted;
      }
      check.finish(outcome, alreadyCompleted: alreadyCompleted);
    }
  }

  Future<Map<String, String>> _getMatchingCookieValues(
    Uri uri,
    ProtectionSession session,
  ) async {
    try {
      final cookies = await _cookieRetriever.getCookies(uri.toString());
      return {
        for (final cookie in cookies)
          if (autoCookieValidator(cookie)) cookie.name: cookie.value,
      };
    } catch (error) {
      session.record(
        ProtectionOperationFailed(
          ProtectionOperation.initialCookieLookup,
          error.runtimeType.toString(),
        ),
      );
      return {};
    }
  }

  bool _hasNewMatchingCookie(
    List<Cookie> cookies,
    Map<String, String> initialCookies,
  ) => cookies.any(
    (cookie) =>
        autoCookieValidator(cookie) &&
        initialCookies[cookie.name] != cookie.value,
  );

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
    pageEvaluator: evaluateCloudflarePage,
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
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
    pageEvaluator: evaluateAftPage,
  );

  @override
  String get protectionType => _solver.protectionType;

  @override
  bool get isSolving => _solver.isSolving;

  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}

Future<String> _getPageSource(WebViewController controller) async {
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

Future<String?> _safeCurrentUrl(
  WebViewController controller,
  ProtectionCheck check,
) async {
  void recordFailure(Object error) => check.record(
    ProtectionOperationFailed(
      ProtectionOperation.currentUrl,
      error.runtimeType.toString(),
    ),
  );
  try {
    // Preserve the existing distinction: an asynchronous failure propagates
    // to the completion check; a synchronous lookup failure yields no URL.
    return await controller.currentUrl().catchError((
      Object error,
      StackTrace stack,
    ) {
      recordFailure(error);
      Error.throwWithStackTrace(error, stack);
    });
  } catch (error) {
    recordFailure(error);
    return null;
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
    ProtectionSession? diagnostics,
  }) => _solver.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
  );

  @override
  Future<void> cancel() => _solver.cancel();
}
