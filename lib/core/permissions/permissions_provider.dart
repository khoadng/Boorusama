// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/permissions/device_storage_permission_notifier.dart';
import 'package:boorusama/core/provider.dart';

final deviceStoragePermissionProvider = NotifierProvider<
    DeviceStoragePermissionNotifier, DeviceStoragePermissionState>(
  DeviceStoragePermissionNotifier.new,
  dependencies: [
    deviceInfoProvider,
    loggerProvider,
  ],
);
