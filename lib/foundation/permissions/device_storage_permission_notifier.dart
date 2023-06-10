// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/permissions/permission.dart';

class DeviceStoragePermissionState extends Equatable {
  const DeviceStoragePermissionState({
    required this.storagePermission,
    required this.isNotificationRead,
  });

  final PermissionStatus storagePermission;
  final bool isNotificationRead;

  DeviceStoragePermissionState copyWith({
    PermissionStatus? storagePermission,
    bool? isNotificationRead,
  }) =>
      DeviceStoragePermissionState(
        storagePermission: storagePermission ?? this.storagePermission,
        isNotificationRead: isNotificationRead ?? this.isNotificationRead,
      );

  @override
  List<Object> get props => [storagePermission, isNotificationRead];
}

class DeviceStoragePermissionNotifier
    extends Notifier<DeviceStoragePermissionState> {
  @override
  DeviceStoragePermissionState build() {
    _fetch();

    return const DeviceStoragePermissionState(
      storagePermission: PermissionStatus.denied,
      isNotificationRead: false,
    );
  }

  Future<void> _fetch() async {
    final logger = ref.watch(loggerProvider);
    logger.logI('Permission', 'Fetching storage permission');
    final status = await Permission.storage.status;

    logger.log(
      'Permission',
      'Storage permission status: ${status.name}',
      level:
          status == PermissionStatus.granted ? LogLevel.info : LogLevel.error,
    );

    state = state.copyWith(storagePermission: status);
  }

  Future<void> requestPermission({
    void Function(bool isGranted)? onDone,
  }) async {
    final deviceInfo = ref.read(deviceInfoProvider);
    final logger = ref.watch(loggerProvider);
    logger.logI('Permission', 'Requesting storage permission');
    final status = await requestMediaPermissions(deviceInfo);
    logger.logI('Permission', 'Storage permission status: $status');

    state = state.copyWith(
      storagePermission: status,
      isNotificationRead: false,
    );

    onDone?.call(status == PermissionStatus.granted);
  }

  void markNotificationAsRead() {
    state = state.copyWith(isNotificationRead: true);
  }
}
