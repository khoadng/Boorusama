// Package imports:
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/infra/device_info_service.dart';
import 'android.dart';

Future<PermissionStatus> requestStoragePermissions(
  DeviceInfo deviceInfo,
) async {
  final statuses = !hasGranularMediaPermissions(deviceInfo)
      ? await [Permission.storage].request()
      : await [Permission.photos, Permission.videos].request();

  final allAccepted =
      statuses.values.every((e) => e == PermissionStatus.granted);

  final otherStatuses =
      statuses.values.where((e) => e != PermissionStatus.granted).firstOrNull;

  return allAccepted
      ? PermissionStatus.granted
      : otherStatuses ?? PermissionStatus.denied;
}
