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
}
