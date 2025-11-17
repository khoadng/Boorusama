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
  });

  final PermissionStatus status;

  bool get isGranted => switch (status) {
    PermissionStatus.granted => true,
    _ => false,
  };

  LocalNetworkPermissionState copyWith({
    PermissionStatus? status,
  }) => LocalNetworkPermissionState(
    status: status ?? this.status,
  );

  @override
  List<Object> get props => [status];
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
    );
  }

  Future<void> requestPermission() async {
    state = const AsyncValue.loading();
    await _handler.request();
    ref.invalidateSelf();
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
