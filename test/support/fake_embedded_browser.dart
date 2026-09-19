import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:boorusama/foundation/browser/types.dart';

final class FakeEmbeddedBrowserSession implements EmbeddedBrowserSession {
  FakeEmbeddedBrowserSession({
    this.browserBackend = BrowserBackend.flutterWebView,
    this.userAgent = 'FakeBrowser/1.0',
  });

  final BrowserBackend browserBackend;
  final _events = StreamController<BrowserEvent>.broadcast();
  final loadedUris = <Uri>[];
  final userAgentOverrides = <String>[];
  final cookiesByUri = <Uri, List<BrowserCookie>>{};
  final javascriptResults = <String, Object?>{};
  Uri? current;
  String? userAgent;
  var disposeCount = 0;
  var disposed = false;

  void emit(BrowserEvent event) {
    if (!disposed) _events.add(event);
  }

  @override
  BrowserBackend get backend => browserBackend;

  @override
  Stream<BrowserEvent> get events => _events.stream;

  @override
  Future<void> load(Uri uri) async {
    if (disposed) throw StateError('disposed');
    loadedUris.add(uri);
    current = uri;
  }

  @override
  Future<void> setUserAgent(String value) async {
    if (disposed) throw StateError('disposed');
    userAgentOverrides.add(value);
    userAgent = value;
  }

  @override
  Future<String?> getUserAgent() async => userAgent;

  @override
  Future<Uri?> currentUri() async => current;

  @override
  Future<Object?> evaluateJavaScript(String source) async =>
      javascriptResults[source];

  @override
  Future<List<BrowserCookie>> getCookies(Uri uri) async =>
      cookiesByUri[uri] ?? const [];

  @override
  Widget buildView({Key? key}) => SizedBox(key: key);

  @override
  Future<void> dispose() async {
    if (disposed) return;
    disposed = true;
    disposeCount++;
    await _events.close();
  }
}

final class FakeEmbeddedBrowserFactory implements EmbeddedBrowserFactory {
  FakeEmbeddedBrowserFactory({
    BrowserAvailability? availability,
    this.defaultUserAgent = 'FakeBrowser/1.0',
    Iterable<EmbeddedBrowserSession>? sessions,
  }) : availability =
           availability ??
           const BrowserAvailability(
             kind: BrowserAvailabilityKind.available,
             backend: BrowserBackend.flutterWebView,
           ),
       _sessions = [...?sessions];

  BrowserAvailability availability;
  String? defaultUserAgent;
  final List<EmbeddedBrowserSession> _sessions;
  @override
  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) async {
    return availability;
  }

  @override
  Future<EmbeddedBrowserSession> createSession() {
    if (_sessions.isEmpty) {
      return Future.error(StateError('No fake browser session queued'));
    }
    return Future.value(_sessions.removeAt(0));
  }

  @override
  Future<String?> getDefaultUserAgent() async {
    return defaultUserAgent;
  }
}
