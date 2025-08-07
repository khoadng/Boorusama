// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/permissions.dart';
import '../types/types.dart';

class BackupUtils {
  static Future<void> ensureStoragePermissions(Ref ref) async {
    final deviceInfo = ref.read(deviceInfoProvider);
    final status = await checkMediaPermissions(deviceInfo);

    if (status != PermissionStatus.granted) {
      final newStatus = await requestMediaPermissions(deviceInfo);
      if (newStatus != PermissionStatus.granted) {
        throw const StoragePermissionDenied();
      }
    }
  }

  static Future<void> replaceFile(
    String sourcePath,
    String destPath,
  ) async {
    final tempPath = '$destPath.${DateTime.now().microsecondsSinceEpoch}.tmp';

    try {
      await File(sourcePath).copy(tempPath);

      final destFile = File(destPath);
      if (destFile.existsSync()) {
        await destFile.delete();
      }

      await File(tempPath).rename(destPath);
    } catch (e) {
      final tempFile = File(tempPath);
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }
}
