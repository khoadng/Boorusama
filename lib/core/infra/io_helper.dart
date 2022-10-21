//TODO: support other platforms

// ignore_for_file: avoid_classes_with_only_static_members

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

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
