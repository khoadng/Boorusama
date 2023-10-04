// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';

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
    extends AsyncNotifier<DeviceStoragePermissionState> {
  @override
  Future<DeviceStoragePermissionState> build() async {
    if (isMobilePlatform()) {
      final logger = ref.watch(loggerProvider);
      final deviceInfo = ref.watch(deviceInfoProvider);

      logger.logI('Permission', 'Fetching storage permission');
      final status = await checkMediaPermissions(deviceInfo);

      logger.log(
        'Permission',
        'Storage permission status: ${status.name}',
        level:
            status == PermissionStatus.granted ? LogLevel.info : LogLevel.error,
      );

      return DeviceStoragePermissionState(
        storagePermission: status,
        isNotificationRead: false,
      );
    } else {
      return const DeviceStoragePermissionState(
        storagePermission: PermissionStatus.granted,
        isNotificationRead: true,
      );
    }
  }

  Future<void> requestPermission({
    void Function(bool isGranted)? onDone,
  }) async {
    final logger = ref.watch(loggerProvider);

    if (state.value == null) {
      logger.logW('Permission', 'Permission state is null');
      return;
    }

    final deviceInfo = ref.read(deviceInfoProvider);
    logger.logI('Permission', 'Requesting storage permission');
    final status = await requestMediaPermissions(deviceInfo);
    logger.logI('Permission', 'Storage permission status: $status');

    state = AsyncData(state.value!.copyWith(
      storagePermission: status,
      isNotificationRead: false,
    ));

    onDone?.call(status == PermissionStatus.granted);
  }

  void markNotificationAsRead() {
    final logger = ref.watch(loggerProvider);
    if (state.value == null) {
      logger.logW('Permission', 'Permission state is null');
      return;
    }

    state = AsyncData(state.value!.copyWith(isNotificationRead: true));
  }
}
