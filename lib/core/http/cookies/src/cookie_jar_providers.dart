// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
