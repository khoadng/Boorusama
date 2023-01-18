// Package imports:
import 'package:device_info_plus/device_info_plus.dart';

// Project imports:
import 'package:boorusama/core/core.dart';

bool hasScopedStorage(AndroidDeviceInfo info) =>
    isAndroid() && info.version.sdkInt >= 29;

bool hasGranularMediaPermissions(AndroidDeviceInfo info) =>
    isAndroid() && info.version.sdkInt >= 33;
