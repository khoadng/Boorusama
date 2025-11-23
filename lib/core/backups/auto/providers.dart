// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/platform.dart';
import '../../downloads/path/types.dart';
import '../sources/providers.dart';
import '../zip/bulk_backup_service.dart';
import 'repo.dart';
import 'service.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((ref) {
  return AutoBackupService(
    bulkBackupService: ref.watch(bulkBackupServiceProvider),
    logger: ref.watch(loggerProvider),
    registry: ref.watch(backupRegistryProvider),
    repository: ref.watch(autoBackupRepositoryProvider),
  );
});

final autoBackupDefaultDirectoryPathProvider = FutureProvider<String?>((
  ref,
) async {
  if (isAndroid()) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    final hasScopeStorage =
        hasScopedStorage(
          deviceInfo.androidDeviceInfo?.version.sdkInt,
        ) ??
        true;

    // On scoped storage, force user to pick a location
    if (hasScopeStorage) return null;
  }

  final result = await tryGetDownloadDirectory();
  final downloadsDir = switch (result) {
    DownloadDirectorySuccess(:final directory) => directory,
    DownloadDirectoryFailure(:final message) => throw Exception(
      message ?? 'Could not find downloads directory',
    ),
  };

  return p.join(downloadsDir.path, AutoBackupService.backupFolderName);
});
