// Dart imports:
import 'dart:io';

// Project imports:
import '../platform.dart';
import 'path_utils.dart';

const _kAppTemporaryDirectoryName = String.fromEnvironment('APP_NAME');

Future<String?> getAppTemporaryPath() async {
  return (await getAppTemporaryDirectory())?.path;
}

Future<Directory?> getAppTemporaryDirectory() async {
  final dir = await getTemporaryDirectory();

  // On Windows, the temporary directory is a global directory so we need to create a subdirectory for the app to avoid deleting other app's files
  if (isWindows()) {
    final name = _getAppWindowsTemporaryDirectoryName();

    final appDir = Directory(join(dir.path, name));
    if (!appDir.existsSync()) {
      await appDir.create();
    }
    return appDir;
  }

  return dir;
}

String _getAppWindowsTemporaryDirectoryName() {
  final name = _kAppTemporaryDirectoryName.isNotEmpty
      ? _kAppTemporaryDirectoryName
      : 'boorusama';

  final sanitized = name.replaceAll(' ', '_').toLowerCase();

  return sanitized;
}

Future<Directory?> getAppDocumentsDirectory() {
  return getApplicationDocumentsDirectory();
}
