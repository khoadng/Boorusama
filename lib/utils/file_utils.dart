// Package imports:
import 'package:path_provider/path_provider.dart';

Future<int> getCacheSize() async {
  int cacheSize = 0;
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.listSync().forEach((file) {
      cacheSize += file.statSync().size;
    });
  }
  return cacheSize;
}

Future<void> clearCache() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}
