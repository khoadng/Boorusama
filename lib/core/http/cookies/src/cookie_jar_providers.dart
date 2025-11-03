// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'cookie_utils.dart';

final cookieCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
  name: 'cookieCacheDirProvider',
);

final cookieJarProvider = Provider<CookieJar>((ref) {
  final cacheDir = ref.watch(cookieCacheDirProvider);

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
