// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/browser/cookie_conversion.dart';
import '../../../../../foundation/browser/flutter_embedded_browser.dart';
import '../../../../../foundation/browser/types.dart';
import '../../../widgets/embedded_browser_host.dart';
import 'page_inspection.dart';
import 'protection_diagnostics.dart';
import 'protection_overlay.dart';

abstract class ProtectionSolver {
  String get protectionType;
  bool get isSolving;

  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  });

  Future<void> cancel();
}

typedef ContextProvider = BuildContext? Function();

abstract class CookieRetriever {
  Future<List<Cookie>> getCookies(String url);
}

final class _SessionCookieRetriever implements CookieRetriever {
  _SessionCookieRetriever(this.session, this.conversionNow);

  final EmbeddedBrowserSession session;
  final DateTime Function() conversionNow;

  @override
  Future<List<Cookie>> getCookies(String url) async {
    final uri = Uri.parse(url);
    return browserCookiesForRequest(
      uri: uri,
      cookies: await session.getCookies(uri),
      now: conversionNow(),
    );
  }
}

final class _RawSolverRun {
  _RawSolverRun(this.session);

  final ProtectionSession session;
  EmbeddedBrowserSession? browser;
  Map<String, String> initialCookies = const {};
  Timer? pollTimer;
  Future<bool>? inFlightCheck;
  DialogRoute<bool>? route;
  NavigatorState? navigator;
  Future<void> Function()? cancel;
  var generation = 0;
  var pageFinished = false;
  var mainFrameFailed = false;
  var terminal = false;
  String? effectiveUserAgent;
  final browserReady = ValueNotifier<bool>(false);
}

class RawSolver implements ProtectionSolver {
  RawSolver({
    required this.protectionType,
    required this.protectionTitle,
    required this.autoCookieValidator,
    required this.contextProvider,
    required this.cookieJar,
    this.pageEvaluator,
    this.cookieRetriever,
    EmbeddedBrowserFactory? browserFactory,
  }) : browserFactory = browserFactory ?? FlutterEmbeddedBrowserFactory();

  @override
  final String protectionType;
  final String protectionTitle;
  final bool Function(Cookie) autoCookieValidator;
  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final PageEvaluator? pageEvaluator;
  final CookieRetriever? cookieRetriever;
  final EmbeddedBrowserFactory browserFactory;
  _RawSolverRun? _run;
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
    final run = _RawSolverRun(session);
    _run = run;
    session.record(
      const SolverStarted(),
      sensitive: ProtectionRequestDetails(uri, userAgent: userAgent),
    );

    final context = contextProvider();
    if (context == null || !context.mounted) {
      session.record(
        RecoveryStopped(
          context == null
              ? RecoveryStopReason.noContext
              : RecoveryStopReason.unmountedContext,
        ),
      );
      _finishSolver(run);
      return false;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    run.navigator = navigator;
    final jar = await cookieJar();
    if (!navigator.mounted) {
      session.record(
        const RecoveryStopped(RecoveryStopReason.unmountedContext),
      );
      _finishSolver(run);
      return false;
    }

    Future<void> finish(
      bool result,
      DialogCloseTrigger trigger, {
      ProtectionTrace? trace,
    }) async {
      if (run.terminal) return;
      run.terminal = true;
      run.generation++;
      run.pollTimer?.cancel();
      run.pollTimer = null;
      run.browserReady.value = false;
      final route = run.route;
      (trace ?? session).record(
        DialogCloseRequested(
          trigger: trigger,
          navigatorId: identityHashCode(navigator),
          routeId: route == null ? null : identityHashCode(route),
          routeIsCurrent: route?.isCurrent,
          canPop: navigator.canPop(),
          alreadyCompleted: false,
        ),
      );
      if (route != null && route.isActive) {
        if (route.isCurrent) {
          navigator.pop(result);
        } else {
          navigator.removeRoute(route, result);
        }
      }
    }

    run.cancel = () => finish(false, DialogCloseTrigger.cancel);

    try {
      session.record(const DialogOpening());
      final result = await showDialog<bool>(
        context: navigator.context,
        barrierDismissible: false,
        routeSettings: const RouteSettings(name: 'challenge_solver'),
        builder: (dialogContext) {
          final route = ModalRoute.of(dialogContext);
          if (route is DialogRoute<bool>) {
            run.route = route;
            session.record(DialogPresented(identityHashCode(route)));
          }
          return Dialog.fullscreen(
            child: ProtectionOverlay(
              url: uri.toString(),
              browserReady: run.browserReady,
              browser: EmbeddedBrowserHost(
                factory: browserFactory,
                initialUri: uri,
                userAgent: userAgent,
                onSessionClosing: () {
                  run.browser = null;
                  run.generation++;
                  run.pollTimer?.cancel();
                  run.pollTimer = null;
                  run.pageFinished = false;
                  run.mainFrameFailed = false;
                  run.browserReady.value = false;
                },
                onFailure: (error) => session.record(
                  ProtectionOperationFailed(
                    ProtectionOperation.webViewSetup,
                    error.code ?? error.reason.name,
                  ),
                ),
                onEvent: (event) {
                  if (run.terminal) return;
                  switch (event.kind) {
                    case BrowserEventKind.navigationStarted:
                      run.pageFinished = false;
                      run.mainFrameFailed = false;
                      session.record(
                        PageNavigationObserved(
                          PageNavigationPhase.started,
                          event.uri?.host,
                        ),
                        sensitive: ProtectionNavigationDetails(
                          event.uri?.toString() ?? '',
                        ),
                      );
                    case BrowserEventKind.urlChanged:
                      break;
                    case BrowserEventKind.navigationCompleted:
                      run.pageFinished = true;
                      session.record(
                        PageNavigationObserved(
                          PageNavigationPhase.finished,
                          event.uri?.host,
                        ),
                        sensitive: ProtectionNavigationDetails(
                          event.uri?.toString() ?? '',
                        ),
                      );
                      unawaited(
                        _check(
                          run: run,
                          uri: uri,
                          jar: jar,
                          trigger: CheckTrigger.pageFinished,
                          finish: (check) => finish(
                            true,
                            DialogCloseTrigger.pageFinished,
                            trace: check,
                          ),
                        ),
                      );
                    case BrowserEventKind.loadError:
                      if (event.isForMainFrame ?? true) {
                        run.mainFrameFailed = true;
                        session.record(
                          WebResourceFailed(
                            code: event.errorCode ?? -1,
                            type: event.errorType,
                            mainFrame: event.isForMainFrame,
                          ),
                        );
                      }
                  }
                },
                onReady: (browser) async {
                  run.browser = browser;
                  run.generation++;
                  run.pageFinished = false;
                  run.mainFrameFailed = false;
                  final effectiveRetriever =
                      cookieRetriever ??
                      _SessionCookieRetriever(browser, DateTime.now);
                  try {
                    final cookies = await effectiveRetriever.getCookies(
                      uri.toString(),
                    );
                    run.initialCookies = {
                      for (final cookie in cookies)
                        if (autoCookieValidator(cookie))
                          cookie.name: cookie.value,
                    };
                    session.record(
                      CookieLookupCompleted(
                        CookieStore.webView,
                        run.initialCookies.length,
                        matchingOnly: true,
                      ),
                    );
                    var actualUserAgent = userAgent?.trim().isNotEmpty ?? false
                        ? userAgent
                        : null;
                    if (actualUserAgent == null) {
                      try {
                        actualUserAgent = await browser.getUserAgent();
                      } catch (_) {
                        // Older Flutter WebView platform fakes may not expose
                        // UA lookup. The visible mobile browser can still
                        // operate; Windows requires a known UA for handoff.
                      }
                    }
                    if (browser.backend == BrowserBackend.windowsWebView2 &&
                        (actualUserAgent == null ||
                            actualUserAgent.trim().isEmpty)) {
                      throw const EmbeddedBrowserException(
                        reason:
                            EmbeddedBrowserFailureReason.initializationFailed,
                        code: 'user_agent_unavailable',
                      );
                    }
                    run.effectiveUserAgent = actualUserAgent;
                    run.browserReady.value = true;
                    run.pollTimer = Timer.periodic(
                      const Duration(seconds: 1),
                      (_) => unawaited(
                        _check(
                          run: run,
                          uri: uri,
                          jar: jar,
                          trigger: CheckTrigger.timer,
                          finish: (check) => finish(
                            true,
                            DialogCloseTrigger.timer,
                            trace: check,
                          ),
                        ),
                      ),
                    );
                  } catch (error) {
                    session.record(
                      ProtectionOperationFailed(
                        ProtectionOperation.initialCookieLookup,
                        error.runtimeType.toString(),
                      ),
                    );
                    if (error is EmbeddedBrowserException) rethrow;
                  }
                },
              ),
              onCancel: () =>
                  unawaited(finish(false, DialogCloseTrigger.cancel)),
              onSolved: () => unawaited(
                _check(
                  run: run,
                  uri: uri,
                  jar: jar,
                  trigger: CheckTrigger.manual,
                  finish: (check) => finish(
                    true,
                    DialogCloseTrigger.manual,
                    trace: check,
                  ),
                ),
              ),
            ),
          );
        },
      );
      session.record(DialogClosed(result));
      return result ?? false;
    } catch (error) {
      session.record(
        ProtectionOperationFailed(
          ProtectionOperation.solver,
          error.runtimeType.toString(),
        ),
      );
      return false;
    } finally {
      run.pollTimer?.cancel();
      run.browserReady.dispose();
      if (identical(_run, run)) _run = null;
      _solving = false;
    }
  }

  Future<bool> _check({
    required _RawSolverRun run,
    required Uri uri,
    required CookieJar jar,
    required CheckTrigger trigger,
    required Future<void> Function(ProtectionCheck check) finish,
  }) {
    final previous = run.inFlightCheck;
    if (previous != null) return previous;
    final check = run.session.beginCheck(trigger);
    late Future<bool> current;
    current =
        _completeIfSolved(
          run: run,
          check: check,
          uri: uri,
          jar: jar,
          finish: finish,
        ).whenComplete(() {
          if (identical(run.inFlightCheck, current)) run.inFlightCheck = null;
        });
    run.inFlightCheck = current;
    return current;
  }

  Future<bool> _completeIfSolved({
    required _RawSolverRun run,
    required ProtectionCheck check,
    required Uri uri,
    required CookieJar jar,
    required Future<void> Function(ProtectionCheck check) finish,
  }) async {
    var outcome = CheckOutcome.failed;
    try {
      if (!_active(run)) {
        outcome = CheckOutcome.alreadyCompleted;
        return false;
      }
      final browser = run.browser;
      if (browser == null || !run.browserReady.value) return false;
      final generation = run.generation;
      final retriever =
          cookieRetriever ?? _SessionCookieRetriever(browser, DateTime.now);
      final cookies = await retriever.getCookies(uri.toString());
      if (!_active(run) || run.generation != generation) return false;
      final currentUrl = await _safeCurrentUrl(browser, check);
      if (!_active(run) || run.generation != generation) return false;
      final changed = _hasNewMatchingCookie(cookies, run.initialCookies);
      check.record(
        CookiesObserved(
          count: cookies.length,
          matching: cookies.where(autoCookieValidator).length,
          changed: changed,
          currentHost: Uri.tryParse(currentUrl ?? '')?.host,
        ),
      );
      final evaluator = pageEvaluator;
      if (evaluator == null) {
        if (!changed) {
          outcome = CheckOutcome.cookieOnly;
          return false;
        }
        await jar.saveFromResponse(uri, cookies);
        if (!_active(run) || run.generation != generation) return false;
        _recordCredentials(run, cookies);
        outcome = CheckOutcome.changedCookie;
        await finish(check);
        return true;
      }

      // A challenge can write its clearance cookie before the browser has
      // finished the verification navigation. Treating that cookie alone as
      // success closes WebView2 mid-challenge and hands an unusable token to
      // the HTTP client. Solvers with page heuristics must confirm the finished
      // document before exporting any cookies.
      if (!run.pageFinished || run.mainFrameFailed) {
        outcome = CheckOutcome.pageNotFinished;
        return false;
      }
      final current = Uri.tryParse(currentUrl ?? '');
      if (current == null || !_sameOrigin(current, uri)) {
        outcome = CheckOutcome.pageRejected;
        return false;
      }
      final evaluation = await inspectChallengePage(
        readSource: () => _getPageSource(browser),
        evaluate: evaluator,
        diagnostics: check,
      );
      if (!_active(run) || run.generation != generation) return false;
      if (!evaluation.accepted) {
        outcome = CheckOutcome.pageRejected;
        return false;
      }
      if (cookies.isNotEmpty) await jar.saveFromResponse(uri, cookies);
      if (!_active(run) || run.generation != generation) return false;
      _recordCredentials(run, cookies);
      outcome = CheckOutcome.pageAccepted;
      await finish(check);
      return true;
    } catch (error) {
      check.record(
        ProtectionOperationFailed(
          ProtectionOperation.completionCheck,
          error.runtimeType.toString(),
        ),
      );
      return false;
    } finally {
      check.finish(outcome, alreadyCompleted: run.terminal);
    }
  }

  bool _active(_RawSolverRun run) =>
      identical(_run, run) && !run.terminal && _solving;

  void _recordCredentials(_RawSolverRun run, List<Cookie> cookies) {
    run.session.observeCompletion({
      for (final cookie in cookies)
        if (autoCookieValidator(cookie)) cookie.name: cookie.value,
    }, run.effectiveUserAgent);
  }

  bool _hasNewMatchingCookie(
    List<Cookie> cookies,
    Map<String, String> initialCookies,
  ) => cookies.any(
    (cookie) =>
        autoCookieValidator(cookie) &&
        initialCookies[cookie.name] != cookie.value,
  );

  void _finishSolver(_RawSolverRun run) {
    run.terminal = true;
    _solving = false;
    run.browserReady.dispose();
  }

  @override
  Future<void> cancel() async {
    final run = _run;
    if (run == null) return;
    await run.cancel?.call();
  }
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
    this.browserFactory,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final EmbeddedBrowserFactory? browserFactory;
  RawSolver? _solver;

  RawSolver get _solverInstance => _solver ??= RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    browserFactory: browserFactory,
    protectionType: protectionType,
    protectionTitle: 'Solving Cloudflare Challenge',
    autoCookieValidator: (cookie) =>
        cookie.name.toLowerCase() == 'cf_clearance',
    pageEvaluator: evaluateCloudflarePage,
  );

  @override
  String get protectionType => 'cloudflare';
  @override
  bool get isSolving => _solver?.isSolving ?? false;
  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) => _solverInstance.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
  );
  @override
  Future<void> cancel() => _solver?.cancel() ?? Future.value();
}

class AftSolver implements ProtectionSolver {
  AftSolver({
    required this.contextProvider,
    required this.cookieJar,
    this.browserFactory,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final EmbeddedBrowserFactory? browserFactory;
  RawSolver? _solver;

  RawSolver get _solverInstance => _solver ??= RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    browserFactory: browserFactory,
    protectionType: protectionType,
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
  String get protectionType => 'aft';
  @override
  bool get isSolving => _solver?.isSolving ?? false;
  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) => _solverInstance.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
  );
  @override
  Future<void> cancel() => _solver?.cancel() ?? Future.value();
}

Future<String> _getPageSource(EmbeddedBrowserSession session) async {
  final result = await session.evaluateJavaScript('''
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
  EmbeddedBrowserSession session,
  ProtectionCheck check,
) async {
  try {
    return (await session.currentUri())?.toString();
  } catch (error) {
    check.record(
      ProtectionOperationFailed(
        ProtectionOperation.currentUrl,
        error.runtimeType.toString(),
      ),
    );
    return null;
  }
}

bool _sameOrigin(Uri a, Uri b) =>
    a.scheme == b.scheme && a.host == b.host && a.port == b.port;

class CaptchaAccessDeniedSolver implements ProtectionSolver {
  CaptchaAccessDeniedSolver({
    required this.contextProvider,
    required this.cookieJar,
    this.browserFactory,
  });

  final ContextProvider contextProvider;
  final LazyAsync<CookieJar> cookieJar;
  final EmbeddedBrowserFactory? browserFactory;
  RawSolver? _solver;

  RawSolver get _solverInstance => _solver ??= RawSolver(
    contextProvider: contextProvider,
    cookieJar: cookieJar,
    browserFactory: browserFactory,
    protectionType: protectionType,
    protectionTitle: 'Solving CAPTCHA',
    autoCookieValidator: (cookie) {
      final cookieName = cookie.name.toLowerCase();
      return cookieName == 'cf_clearance' || cookieName.contains('clearance');
    },
  );

  @override
  String get protectionType => 'captcha_access_denied';
  @override
  bool get isSolving => _solver?.isSolving ?? false;
  @override
  Future<bool> solve({
    required Uri uri,
    String? userAgent,
    ProtectionSession? diagnostics,
  }) => _solverInstance.solve(
    uri: uri,
    userAgent: userAgent,
    diagnostics: diagnostics,
  );
  @override
  Future<void> cancel() => _solver?.cancel() ?? Future.value();
}
