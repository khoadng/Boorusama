// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/path.dart';

final cookieCacheDirPathProvider = Provider<LazyAsync<String?>>(
  (ref) => LazyAsync(() async {
    final tempPath = await getAppTemporaryPath();

    return tempPath;
  }),
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
