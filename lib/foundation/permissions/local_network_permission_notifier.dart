// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'local_network.dart';
import 'permissions_provider.dart';

class LocalNetworkPermissionState extends Equatable {
  const LocalNetworkPermissionState({
    required this.status,
    required this.isChecked,
  });

  final PermissionStatus status;
  final bool isChecked;

  bool get isGranted => switch (status) {
    PermissionStatus.granted => true,
    _ => false,
  };

  bool get isDenied => switch (status) {
    PermissionStatus.denied => true,
    _ => false,
  };

  bool get isPermanentlyDenied => switch (status) {
    PermissionStatus.permanentlyDenied => true,
    _ => false,
  };

  LocalNetworkPermissionState copyWith({
    PermissionStatus? status,
    bool? isChecked,
  }) => LocalNetworkPermissionState(
    status: status ?? this.status,
    isChecked: isChecked ?? this.isChecked,
  );

  @override
  List<Object> get props => [status, isChecked];
}

class LocalNetworkPermissionNotifier
    extends AsyncNotifier<LocalNetworkPermissionState> {
  LocalNetworkPermissionHandler get _handler =>
      ref.read(localNetworkPermissionHandlerProvider);

  @override
  Future<LocalNetworkPermissionState> build() async {
    final status = await _handler.check();

    return LocalNetworkPermissionState(
      status: status,
      isChecked: true,
    );
  }

  Future<void> requestPermission() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentState = await future;
      final status = await _handler.request();
      return currentState.copyWith(status: status);
    });
  }

  Future<void> checkPermission() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentState = await future;
      final status = await _handler.check();
      return currentState.copyWith(status: status);
    });
  }
}

final localNetworkPermissionProvider =
    AsyncNotifierProvider<
      LocalNetworkPermissionNotifier,
      LocalNetworkPermissionState
    >(
      LocalNetworkPermissionNotifier.new,
      dependencies: [
        localNetworkPermissionHandlerProvider,
      ],
    );
