//TODO: support other platforms

// ignore_for_file: avoid_classes_with_only_static_members

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

class IOHelper {
  static Future<String> getDownloadPath() async {
    if (isAndroid()) {
      final root = Directory.fromUri(Uri(path: '/storage/emulated/0/Download'));

      return root.path;
    } else if (isWindows()) {
      final root = (await getDownloadsDirectory()) ??
          (await getApplicationDocumentsDirectory());

      return root.path;
    } else {
      final root = await getApplicationDocumentsDirectory();

      return root.path;
    }
  }
}

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (_) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();

    return newFile;
  }
}

String fixInvalidCharacterForPathName(String str) =>
    str.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
