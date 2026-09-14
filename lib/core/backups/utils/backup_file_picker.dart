// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:foundation/foundation.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../../foundation/picker.dart';
import '../../../../foundation/platform.dart';

class BackupFilePicker {
  static Future<void> pickFile({
    required BuildContext context,
    required AppPlatform platform,
    required AndroidDeviceInfo? androidDeviceInfo,
    required void Function(String path) onPick,
    List<String> allowedExtensions = const ['json'],
    bool forceAnyFileType = false,
  }) {
    if (forceAnyFileType) {
      return _pickFileManualExtensionCheck(context, allowedExtensions, onPick);
    }

    if (platform.isAndroid) {
      final androidVersion = androidDeviceInfo?.version.sdkInt;
      // Android 9 or lower will need to use any file type
      if (androidVersion != null &&
          androidVersion <= AndroidVersions.android9.apiLevel) {
        return _pickFileManualExtensionCheck(
          context,
          allowedExtensions,
          onPick,
        );
      }
    }

    return pickSingleFilePathToastOnError(
      context: context,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      onPick: onPick,
    );
  }

  static Future<void> _pickFileManualExtensionCheck(
    BuildContext context,
    List<String> allowedExtensions,
    void Function(String path) onPick,
  ) => pickSingleFilePathToastOnError(
    context: context,
    onPick: (path) {
      final ext = p.extension(path);

      if (!allowedExtensions.contains(ext.substring(1))) {
        Kurumi.showErrorToast(
          context,
          'Invalid file type, only ${allowedExtensions.map((e) => '.$e').join(', ')} files are allowed',
        );
        return;
      }

      onPick(path);
    },
  );
}
