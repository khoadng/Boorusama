// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../platform.dart';

Future<String> getAppStoragePath() async {
  if (isWeb()) return '';

  final dir = isAndroid()
      ? await getApplicationDocumentsDirectory()
      : await getApplicationSupportDirectory();

  return dir.path;
}
