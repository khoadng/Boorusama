// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'types.dart';

final class FlutterEmbeddedBrowserFactory implements EmbeddedBrowserFactory {
  FlutterEmbeddedBrowserFactory();

  String? _userAgent;
  Future<String?>? _userAgentFuture;

  @override
  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) async => const BrowserAvailability(
    kind: BrowserAvailabilityKind.available,
    backend: BrowserBackend.flutterWebView,
  );

  @override
  Future<EmbeddedBrowserSession> createSession() async {
    final controller = WebViewController();
    final session = _FlutterEmbeddedBrowserSession(controller);
    try {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(session.navigationDelegate);
      return session;
    } catch (error) {
      await session.dispose();
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
    try {
      final value = await WebViewController().getUserAgent();
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        _userAgent = normalized;
      }
      return _userAgent;
    } catch (_) {
      return null;
    } finally {
      _userAgentFuture = null;
    }
  }
}

final class _FlutterEmbeddedBrowserSession implements EmbeddedBrowserSession {
  _FlutterEmbeddedBrowserSession(this._controller);

  final WebViewController _controller;
  final _events = StreamController<BrowserEvent>.broadcast();
  var _disposed = false;

  NavigationDelegate get navigationDelegate => NavigationDelegate(
    onPageStarted: (url) => _emit(
      BrowserEvent(
        kind: BrowserEventKind.navigationStarted,
        uri: Uri.tryParse(url),
      ),
    ),
    onPageFinished: (url) => _emit(
      BrowserEvent(
        kind: BrowserEventKind.navigationCompleted,
        uri: Uri.tryParse(url),
      ),
    ),
    onWebResourceError: (error) => _emit(
      BrowserEvent(
        kind: BrowserEventKind.loadError,
        errorCode: error.errorCode,
        errorType: error.errorType?.name,
        isForMainFrame: error.isForMainFrame,
      ),
    ),
  );

  @override
  BrowserBackend get backend => BrowserBackend.flutterWebView;

  @override
  Stream<BrowserEvent> get events => _events.stream;

  EmbeddedBrowserException get _disposedError => const EmbeddedBrowserException(
    reason: EmbeddedBrowserFailureReason.disposedSession,
  );

  void _checkAlive() {
    if (_disposed) throw _disposedError;
  }

  void _emit(BrowserEvent event) {
    if (!_disposed && !_events.isClosed) _events.add(event);
  }

  @override
  Future<void> load(Uri uri) async {
    _checkAlive();
    await _controller.loadRequest(uri);
  }

  @override
  Future<void> setUserAgent(String userAgent) async {
    _checkAlive();
    await _controller.setUserAgent(userAgent);
  }

  @override
  Future<String?> getUserAgent() {
    _checkAlive();
    return _controller.getUserAgent();
  }

  @override
  Future<Uri?> currentUri() async {
    _checkAlive();
    return Uri.tryParse(await _controller.currentUrl() ?? '');
  }

  @override
  Future<Object?> evaluateJavaScript(String source) {
    _checkAlive();
    return _controller.runJavaScriptReturningResult(source);
  }

  @override
  Future<List<BrowserCookie>> getCookies(Uri uri) async {
    _checkAlive();
    final cookies = await WebViewCookieManager().getCookies(domain: uri);
    return [
      for (final cookie in cookies)
        BrowserCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain,
          path: cookie.path,
        ),
    ];
  }

  @override
  Widget buildView({Key? key}) {
    _checkAlive();
    return WebViewWidget(key: key, controller: _controller);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _events.close();
  }
}
