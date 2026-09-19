// Flutter imports:
import 'package:flutter/widgets.dart';

enum BrowserBackend { flutterWebView, windowsWebView2, unsupported }

enum BrowserAvailabilityKind {
  available,
  unsupportedPlatform,
  runtimeMissing,
  initializationFailed,
}

final class BrowserAvailability {
  const BrowserAvailability({
    required this.kind,
    required this.backend,
    this.runtimeVersion,
    this.failureCode,
  });

  final BrowserAvailabilityKind kind;
  final BrowserBackend backend;
  final String? runtimeVersion;
  final String? failureCode;

  bool get isAvailable => kind == BrowserAvailabilityKind.available;
}

enum BrowserEventKind {
  navigationStarted,
  urlChanged,
  navigationCompleted,
  loadError,
}

final class BrowserEvent {
  const BrowserEvent({
    required this.kind,
    this.uri,
    this.errorCode,
    this.errorType,
    this.isForMainFrame,
  });

  final BrowserEventKind kind;
  final Uri? uri;
  final int? errorCode;
  final String? errorType;
  final bool? isForMainFrame;
}

enum BrowserCookieSameSite { none, lax, strict }

final class BrowserCookie {
  const BrowserCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.path,
    this.expiresUtc,
    this.isSecure,
    this.isHttpOnly,
    this.sameSite,
  });

  final String name;
  final String value;
  final String domain;
  final String path;
  final DateTime? expiresUtc;
  final bool? isSecure;
  final bool? isHttpOnly;
  final BrowserCookieSameSite? sameSite;
}

enum EmbeddedBrowserFailureReason {
  unsupportedPlatform,
  runtimeMissing,
  initializationFailed,
  operationTimeout,
  disposedSession,
}

final class EmbeddedBrowserException implements Exception {
  const EmbeddedBrowserException({
    required this.reason,
    this.code,
  });

  final EmbeddedBrowserFailureReason reason;
  final String? code;

  @override
  String toString() => code == null
      ? 'EmbeddedBrowserException(${reason.name})'
      : 'EmbeddedBrowserException(${reason.name}, code: $code)';
}

abstract interface class EmbeddedBrowserSession {
  BrowserBackend get backend;
  Stream<BrowserEvent> get events;

  Future<void> load(Uri uri);
  Future<void> setUserAgent(String userAgent);
  Future<String?> getUserAgent();
  Future<Uri?> currentUri();
  Future<Object?> evaluateJavaScript(String source);
  Future<List<BrowserCookie>> getCookies(Uri uri);

  Widget buildView({Key? key});
  Future<void> dispose();
}

abstract interface class EmbeddedBrowserFactory {
  Future<BrowserAvailability> checkAvailability({bool forceRefresh = false});
  Future<EmbeddedBrowserSession> createSession();
  Future<String?> getDefaultUserAgent();
}
