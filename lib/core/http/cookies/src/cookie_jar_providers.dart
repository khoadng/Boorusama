// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';

final cookieCacheDirPathProvider = Provider<LazyAsync<String?>>(
  (ref) {
    final fs = ref.watch(appFileSystemProvider);
    return LazyAsync(() async {
      final tempPath = await fs.getTemporaryPath();

      return tempPath;
    });
  },
  name: 'cookieCacheDirProvider',
);

final cookieJarProvider = Provider<LazyAsync<CookieJar>>((ref) {
  final pathLazy = ref.watch(cookieCacheDirPathProvider);
  return LazyAsync(() async {
    final path = await pathLazy();
    return PersistCookieJar(
      storage: FileStorage(path),
    );
  });
});
