// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/permissions/device_storage_permission_notifier.dart';

final deviceStoragePermissionProvider = NotifierProvider<
    DeviceStoragePermissionNotifier, DeviceStoragePermissionState>(
  DeviceStoragePermissionNotifier.new,
  dependencies: [
    deviceInfoProvider,
    loggerProvider,
  ],
);
