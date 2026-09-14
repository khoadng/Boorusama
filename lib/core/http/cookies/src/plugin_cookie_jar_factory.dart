// Package imports:
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';
import 'cookie_jar_factory.dart';

final class PluginCookieJarFactory implements CookieJarFactory {
  const PluginCookieJarFactory({required this.fileSystem});

  final AppFileSystem fileSystem;

  @override
  Future<CookieJar> create() async {
    final path = await fileSystem.getTemporaryPath();

    return PersistCookieJar(
      storage: FileStorage(path),
    );
  }
}
