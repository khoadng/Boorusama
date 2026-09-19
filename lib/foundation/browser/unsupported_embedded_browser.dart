// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'types.dart';

final class UnsupportedEmbeddedBrowserFactory
    implements EmbeddedBrowserFactory {
  const UnsupportedEmbeddedBrowserFactory();

  @override
  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) async => const BrowserAvailability(
    kind: BrowserAvailabilityKind.unsupportedPlatform,
    backend: BrowserBackend.unsupported,
  );

  @override
  Future<EmbeddedBrowserSession> createSession() => Future.error(
    const EmbeddedBrowserException(
      reason: EmbeddedBrowserFailureReason.unsupportedPlatform,
    ),
  );

  @override
  Future<String?> getDefaultUserAgent() => Future.value();
}

final class UnsupportedEmbeddedBrowserSession
    implements EmbeddedBrowserSession {
  const UnsupportedEmbeddedBrowserSession();

  @override
  BrowserBackend get backend => BrowserBackend.unsupported;

  @override
  Stream<BrowserEvent> get events => const Stream.empty();

  EmbeddedBrowserException get _error => const EmbeddedBrowserException(
    reason: EmbeddedBrowserFailureReason.unsupportedPlatform,
  );

  @override
  Future<void> load(Uri uri) => Future.error(_error);

  @override
  Future<void> setUserAgent(String userAgent) => Future.error(_error);

  @override
  Future<String?> getUserAgent() => Future.error(_error);

  @override
  Future<Uri?> currentUri() => Future.error(_error);

  @override
  Future<Object?> evaluateJavaScript(String source) => Future.error(_error);

  @override
  Future<List<BrowserCookie>> getCookies(Uri uri) => Future.error(_error);

  @override
  Widget buildView({Key? key}) => const SizedBox.shrink();

  @override
  Future<void> dispose() async {}
}
