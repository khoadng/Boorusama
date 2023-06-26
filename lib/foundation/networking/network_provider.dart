// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/networking/networking.dart';

const _serviceName = 'Connectivity';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final logger = ref.watch(loggerProvider);
  ref.listenSelf(
    (previous, next) {
      final fn = next.when(
        data: (data) => switch (data) {
          ConnectivityResult.none => () =>
              logger.logW(_serviceName, 'Network disconnected'),
          _ => () => logger.logI(_serviceName, 'Connected to ${data.name}'),
        },
        error: (error, stackTrace) => () => logger.logE(
              _serviceName,
              'Error: $error',
            ),
        loading: () => () => logger.logI(_serviceName, 'Network connecting...'),
      );
      fn.call();
    },
  );

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
