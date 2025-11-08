// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../info/device_info.dart';
import '../loggers.dart';
import 'device_storage_permission_notifier.dart';
import 'permission_utils.dart';

final deviceStoragePermissionProvider =
    AsyncNotifierProvider<
      DeviceStoragePermissionNotifier,
      DeviceStoragePermissionState
    >(
      DeviceStoragePermissionNotifier.new,
      dependencies: [
        deviceInfoProvider,
        loggerProvider,
      ],
    );

final mediaPermissionManagerProvider = Provider<MediaPermissionManager>(
  (ref) => MediaPermissionManager(
    deviceInfo: ref.watch(deviceInfoProvider),
  ),
);

final notificationPermissionManagerProvider =
    Provider<NotificationPermissionManager>(
      (ref) => NotificationPermissionManager(
        logger: ref.watch(loggerProvider),
      ),
    );
