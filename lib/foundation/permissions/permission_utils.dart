// Package imports:
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/platform.dart';

Future<PermissionStatus> requestMediaPermissions(
  DeviceInfo deviceInfo,
) {
  if (isWindows()) return Future.value(PermissionStatus.granted);

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

Future<PermissionStatus> checkMediaPermissions(
  DeviceInfo deviceInfo,
) async {
  if (isAndroid()) {
    return _checkMediaPermissionsAndroid(
      deviceInfo.androidDeviceInfo?.version.sdkInt,
    );
  } else if (isIOS()) {
    return _checkMediaPermissionsIos();
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
        ].request()
      : await [Permission.storage].request();

  // request notification permission separately
  await Permission.notification.request();

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
  ].request();

  // request notification permission separately
  await Permission.notification.request();

  final allAccepted =
      statuses.values.every((e) => e == PermissionStatus.granted);

  return allAccepted
      ? PermissionStatus.granted
      : statuses.values.contains(PermissionStatus.permanentlyDenied)
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.denied;
}

Future<PermissionStatus> _checkMediaPermissionsIos() async {
  final statuses = await Future.wait([
    Permission.storage.status,
  ]);

  final allAccepted = statuses.every((e) => e == PermissionStatus.granted);

  return allAccepted ? PermissionStatus.granted : PermissionStatus.denied;
}

Future<PermissionStatus> _checkMediaPermissionsAndroid(
  AndroidVersion? androidVersion,
) async {
  final hasGranularPerm = hasGranularMediaPermissions(androidVersion);

  if (hasGranularPerm == null) return PermissionStatus.denied;

  final statuses = hasGranularPerm
      ? await Future.wait([
          Permission.photos.status,
          Permission.videos.status,
        ])
      : await Future.wait([
          Permission.storage.status,
        ]);

  final allAccepted = statuses.every((e) => e == PermissionStatus.granted);

  return allAccepted
      ? PermissionStatus.granted
      : statuses.contains(PermissionStatus.permanentlyDenied)
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.denied;
}
