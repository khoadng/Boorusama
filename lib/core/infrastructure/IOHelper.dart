//TODO: use IO service instead of static method

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IOHelper {
  static Future<String> getLocalPath(
      String folderName, TargetPlatform platform) async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path + Platform.pathSeparator + folderName;
  }

  static Future<bool> checkPermission(TargetPlatform platform) async {
    if (platform == TargetPlatform.android) {
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
      return true;
    }
    return false;
  }
}
