// Package imports:
import 'package:foundation/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import '../info/device_info.dart';
import '../platform.dart';

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
    return Future.value(PermissionStatus.granted);
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
  if (hasScopedStorage(androidVersion) == true) {
    return PermissionStatus.granted;
  } else {
    final status = await Permission.storage.request();

    return status;
  }
}

Future<PermissionStatus> _requestMediaPermissionsIos() async {
  final statuses = await [
    Permission.storage,
  ].request();

  final allAccepted = statuses.values.every(
    (e) => e == PermissionStatus.granted,
  );

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
  if (hasScopedStorage(androidVersion) == true) {
    return PermissionStatus.granted;
  } else {
    final status = await Permission.storage.status;

    return status;
  }
}

class NotificationPermissionManager {
  NotificationPermissionManager();

  PermissionStatus? status;

  Future<void> requestIfNotGranted() async {
    final status = await check();

    if (status == PermissionStatus.permanentlyDenied) {
      return;
    }

    if (status != PermissionStatus.granted) {
      await request();
    }
  }

  Future<PermissionStatus> request() {
    return Permission.notification.request();
  }

  Future<PermissionStatus> check() async {
    if (status != null) {
      return status!;
    }

    status = await Permission.notification.status;

    return status!;
  }
}

class MediaPermissionManager {
  MediaPermissionManager({
    required this.deviceInfo,
  });

  final DeviceInfo deviceInfo;

  Future<PermissionStatus> request() {
    return requestMediaPermissions(deviceInfo);
  }

  Future<PermissionStatus> check() {
    return checkMediaPermissions(deviceInfo);
  }
}
