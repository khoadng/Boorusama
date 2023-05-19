// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/networking.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

final networkStateProvider = Provider<NetworkState>((ref) {
  final connectivityResult = ref.watch(connectivityProvider);

  return connectivityResult.when(
    data: (result) => switch (result) {
      ConnectivityResult.none => NetworkDisconnectedState(),
      _ => NetworkConnectedState(),
    },
    loading: () => NetworkLoadingState(),
    error: (_, __) => NetworkDisconnectedState(),
  );
});
