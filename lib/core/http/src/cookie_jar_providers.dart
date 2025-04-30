// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'providers.dart';

final cookieJarProvider = Provider<CookieJar>((ref) {
  final cacheDir = ref.watch(httpCacheDirProvider);

  return PersistCookieJar(
    storage: FileStorage(cacheDir.path),
  );
});

final bypassDdosHeadersProvider =
    FutureProvider.family<Map<String, String>, String>((ref, url) async {
  final cookieJar = ref.watch(cookieJarProvider);

  final cookies = await cookieJar.loadForRequest(Uri.parse(url));

  if (cookies.isEmpty) return const {};

  final cookieString = cookies.cookieString;

  final webviewController = WebViewController();
  final userAgent = await webviewController.getUserAgent();

  return {
    if (cookieString.isNotEmpty) 'cookie': cookieString,
    if (userAgent != null && userAgent.isNotEmpty) 'user-agent': userAgent,
  };
});

final cachedBypassDdosHeadersProvider =
    Provider.family<Map<String, String>, String>((ref, url) {
  final headers = ref.watch(bypassDdosHeadersProvider(url));

  return headers.maybeWhen(
    data: (value) => value,
    orElse: () => const {},
  );
});

extension CookieJarX on List<Cookie> {
  String get cookieString => map((e) => e.toString()).join('; ');
}
