// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:webview_flutter_windows/webview_flutter_windows.dart' as win;

// Project imports:
import 'types.dart';
import 'windows_browser_runtime.dart';

final class WindowsEmbeddedBrowserFactory implements EmbeddedBrowserFactory {
  WindowsEmbeddedBrowserFactory({required this.runtime});

  final WindowsBrowserRuntime runtime;
  String? _userAgent;
  Future<String?>? _userAgentFuture;

  @override
  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) => runtime.checkAvailability(forceRefresh: forceRefresh);

  @override
  Future<EmbeddedBrowserSession> createSession() async {
    final controller = await runtime.acquire();
    try {
      final session = WindowsEmbeddedBrowserSession(
        controller: controller,
        runtime: runtime,
      );
      await controller.setPopupWindowPolicy(
        win.WebviewPopupWindowPolicy.sameWindow,
      );
      await controller.setDefaultContextMenusEnabled(true);
      return session;
    } catch (error) {
      await runtime.release(controller);
      if (error is EmbeddedBrowserException) rethrow;
      throw EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.initializationFailed,
        code: error.runtimeType.toString(),
      );
    }
  }

  @override
  Future<String?> getDefaultUserAgent() {
    final cached = _userAgent;
    if (cached != null) return Future.value(cached);
    return _userAgentFuture ??= _discoverUserAgent();
  }

  Future<String?> _discoverUserAgent() async {
    EmbeddedBrowserSession? session;
    try {
      final availability = await checkAvailability(forceRefresh: true);
      if (!availability.isAvailable) return null;

      final creation = createSession();
      try {
        session = await creation.timeout(const Duration(seconds: 30));
      } catch (error) {
        unawaited(
          creation.then<void>(
            (lateSession) => lateSession.dispose(),
            onError: (_, _) {},
          ),
        );
        return null;
      }

      final completed = session.events.firstWhere(
        (event) => event.kind == BrowserEventKind.navigationCompleted,
      );
      await session.load(Uri.parse('about:blank'));
      await completed.timeout(const Duration(seconds: 5));
      final value = (await session.getUserAgent())?.trim();
      if (value != null && value.isNotEmpty) _userAgent = value;
      return _userAgent;
    } catch (_) {
      return null;
    } finally {
      await session?.dispose();
      _userAgentFuture = null;
    }
  }
}

final class WindowsEmbeddedBrowserSession implements EmbeddedBrowserSession {
  WindowsEmbeddedBrowserSession({
    required win.WebviewController controller,
    required WindowsBrowserRuntime runtime,
  }) : _controller = controller,
       _runtime = runtime {
    _subscriptions.add(
      _controller.url.listen((value) {
        _lastUri = Uri.tryParse(value);
        _emit(BrowserEvent(kind: BrowserEventKind.urlChanged, uri: _lastUri));
      }),
    );
    _subscriptions.add(
      _controller.loadingState.listen((state) {
        if (state == win.LoadingState.loading) {
          _emit(
            BrowserEvent(
              kind: BrowserEventKind.navigationStarted,
              uri: _lastUri,
            ),
          );
        } else if (state == win.LoadingState.navigationCompleted) {
          _emit(
            BrowserEvent(
              kind: BrowserEventKind.navigationCompleted,
              uri: _lastUri,
            ),
          );
        }
      }),
    );
    _subscriptions.add(
      _controller.onLoadError.listen((error) {
        _emit(
          BrowserEvent(
            kind: BrowserEventKind.loadError,
            errorType: error.name,
          ),
        );
      }),
    );
  }

  final win.WebviewController _controller;
  final WindowsBrowserRuntime _runtime;
  final _events = StreamController<BrowserEvent>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  Uri? _lastUri;
  Future<void>? _disposeFuture;
  var _disposed = false;

  @override
  BrowserBackend get backend => BrowserBackend.windowsWebView2;

  @override
  Stream<BrowserEvent> get events => _events.stream;

  void _checkAlive() {
    if (_disposed) {
      throw const EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.disposedSession,
      );
    }
  }

  void _emit(BrowserEvent event) {
    if (!_disposed && !_events.isClosed) _events.add(event);
  }

  @override
  Future<void> load(Uri uri) async {
    _checkAlive();
    await _controller.loadUrl(uri.toString());
  }

  @override
  Future<void> setUserAgent(String userAgent) async {
    _checkAlive();
    await _controller.setUserAgent(userAgent);
  }

  @override
  Future<String?> getUserAgent() async {
    _checkAlive();
    final result = await _controller.executeScript('navigator.userAgent');
    return _scriptString(result);
  }

  @override
  Future<Uri?> currentUri() async {
    _checkAlive();
    final result = await _controller.executeScript('window.location.href');
    return Uri.tryParse(_scriptString(result) ?? '');
  }

  @override
  Future<Object?> evaluateJavaScript(String source) {
    _checkAlive();
    return _controller.executeScript(source);
  }

  @override
  Future<List<BrowserCookie>> getCookies(Uri uri) async {
    _checkAlive();
    final nativeCookies = await _controller.getCookies(uri.toString());
    return [
      for (final cookie in nativeCookies)
        BrowserCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path,
          expiresUtc: cookie.expires?.toUtc(),
          isSecure: cookie.isSecure,
          isHttpOnly: cookie.isHttpOnly,
          sameSite: switch (cookie.sameSite) {
            win.WebviewCookieSameSite.none => BrowserCookieSameSite.none,
            win.WebviewCookieSameSite.lax => BrowserCookieSameSite.lax,
            win.WebviewCookieSameSite.strict => BrowserCookieSameSite.strict,
          },
        ),
    ];
  }

  @override
  Widget buildView({Key? key}) {
    _checkAlive();
    return win.Webview(
      _controller,
      key: key,
      permissionRequested: (_, _, _) => win.WebviewPermissionDecision.deny,
    );
  }

  @override
  Future<void> dispose() => _disposeFuture ??= _dispose();

  Future<void> _dispose() async {
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _events.close();
    await _runtime.release(_controller);
  }
}

String? _scriptString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}
