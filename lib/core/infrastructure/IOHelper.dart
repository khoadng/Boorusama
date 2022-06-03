//TODO: support other platforms

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IOHelper {
  static Future<String> getLocalPath(String folderName) async {
    try {
      return await _getLocalPath(folderName);
    } catch (e) {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      return directory!.path + Platform.pathSeparator + folderName;
    }
  }

  static Future<String> getLocalPathFallback() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  static Future<String> _getLocalPath(String folderName) async {
    Future<String> createDir(Directory root) async =>
        root.path + Platform.pathSeparator + folderName;

    String path = '${Platform.pathSeparator}$folderName';
    if (Platform.isAndroid) {
      final root = Directory.fromUri(Uri(path: '/storage/emulated/0/Download'));

      path = await createDir(root);
    } else if (Platform.isWindows) {
      final root = (await getDownloadsDirectory()) ??
          (await getApplicationDocumentsDirectory());
      path = await createDir(root);
    } else {
      throw UnimplementedError();
    }

    return path;
  }

  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      //TODO: check permission for iOS and other platforms
      return true;
    }
    return false;
  }
}
