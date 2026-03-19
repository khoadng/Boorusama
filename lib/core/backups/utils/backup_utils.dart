// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/filesystem.dart';
import '../../../foundation/info/device_info.dart';
import '../../../foundation/permissions.dart';

class BackupUtils {
  static Future<void> ensureStoragePermissions(Ref ref) async {
    final deviceInfo = ref.read(deviceInfoProvider);
    final status = await checkMediaPermissions(deviceInfo);

    if (status != PermissionStatus.granted) {
      final newStatus = await requestMediaPermissions(deviceInfo);
      if (newStatus != PermissionStatus.granted) {
        throw Exception(
          'Storage permissions are required to perform backups.',
        );
      }
    }
  }

  static Future<void> replaceFile(
    AppFileSystem fs,
    String sourcePath,
    String destPath,
  ) async {
    final tempPath = '$destPath.${DateTime.now().microsecondsSinceEpoch}.tmp';

    try {
      await fs.copyFile(sourcePath, tempPath);

      if (fs.fileExistsSync(destPath)) {
        await fs.deleteFile(destPath);
      }

      await fs.renameFile(tempPath, destPath);
    } catch (e) {
      if (fs.fileExistsSync(tempPath)) {
        await fs.deleteFile(tempPath);
      }
      rethrow;
    }
  }
}
