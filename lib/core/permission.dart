// Package imports:
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/device_info_service.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/platform.dart';

Future<PermissionStatus> requestMediaPermissions(
  DeviceInfo deviceInfo,
) {
  if (isAndroid()) {
    return _requestMediaPermissionsAndroid(
      deviceInfo.androidDeviceInfo?.version.sdkInt,
    );
  } else if (isIOS()) {
    return _requestMediaPermissionsIos();
  } else {
    return Future.value(PermissionStatus.denied);
  }
}

Future<PermissionStatus> _requestMediaPermissionsAndroid(
  AndroidVersion? androidVersion,
) async {
  final hasGranularPerm = hasGranularMediaPermissions(androidVersion);

  if (hasGranularPerm == null) return PermissionStatus.denied;

  final statuses = hasGranularPerm
      ? await [
          Permission.photos,
          Permission.videos,
          Permission.notification,
        ].request()
      : await [Permission.storage].request();

  final allAccepted =
      statuses.values.every((e) => e == PermissionStatus.granted);

  final otherStatuses =
      statuses.values.where((e) => e != PermissionStatus.granted).firstOrNull;

  return allAccepted
      ? PermissionStatus.granted
      : otherStatuses ?? PermissionStatus.denied;
}

Future<PermissionStatus> _requestMediaPermissionsIos() async {
  final statuses = await [
    Permission.storage,
    Permission.notification,
  ].request();

  final allAccepted =
      statuses.values.every((e) => e == PermissionStatus.granted);

  return allAccepted ? PermissionStatus.granted : PermissionStatus.denied;
}
