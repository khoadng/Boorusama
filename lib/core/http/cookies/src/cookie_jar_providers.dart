// Dart imports:
import 'dart:io';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/path.dart';

final cookieCacheDirProvider = Provider<LazyAsync<Directory>>(
  (ref) => LazyAsync(getAppTemporaryDirectory),
  name: 'cookieCacheDirProvider',
);

final cookieJarProvider = Provider<LazyAsync<CookieJar>>((ref) {
  final cacheDir = ref.watch(cookieCacheDirProvider);
  return LazyAsync(() async {
    final dir = await cacheDir();
    return PersistCookieJar(
      storage: FileStorage(dir.path),
    );
  });
});
