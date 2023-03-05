// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/permission.dart';

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

abstract class DeviceStoragePermissionEvent extends Equatable {
  const DeviceStoragePermissionEvent();
}

class DeviceStoragePermissionFetched extends DeviceStoragePermissionEvent {
  @override
  List<Object?> get props => [];
}

class DeviceStoragePermissionRequested extends DeviceStoragePermissionEvent {
  const DeviceStoragePermissionRequested({
    this.onDone,
  });

  final void Function(bool isGranted)? onDone;

  @override
  List<Object?> get props => [onDone];
}

class DeviceStorageNotificationDisplayStatusChanged
    extends DeviceStoragePermissionEvent {
  const DeviceStorageNotificationDisplayStatusChanged({
    required this.isDisplay,
  });

  final bool isDisplay;

  @override
  List<Object?> get props => [isDisplay];
}

class DeviceStoragePermissionBloc
    extends Bloc<DeviceStoragePermissionEvent, DeviceStoragePermissionState> {
  DeviceStoragePermissionBloc({
    required PermissionStatus initialStatus,
    required DeviceInfo deviceInfo,
  }) : super(DeviceStoragePermissionState(
          storagePermission: initialStatus,
          isNotificationRead: false,
        )) {
    on<DeviceStoragePermissionFetched>(
      (event, emit) async {
        final status = await Permission.storage.status;
        emit(state.copyWith(storagePermission: status));
      },
      transformer: droppable(),
    );

    on<DeviceStoragePermissionRequested>(
      (event, emit) async {
        final status = await requestMediaPermissions(deviceInfo);

        event.onDone?.call(status == PermissionStatus.granted);

        emit(state.copyWith(
          storagePermission: status,
          isNotificationRead: false,
        ));
      },
      transformer: droppable(),
    );

    on<DeviceStorageNotificationDisplayStatusChanged>((event, emit) {
      emit(state.copyWith(isNotificationRead: event.isDisplay));
    });
  }
}
