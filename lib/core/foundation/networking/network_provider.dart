// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../loggers.dart';
import 'network_state.dart';

const _serviceName = 'Connectivity';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final networkStateProvider = Provider<NetworkState>((ref) {
  return ref.watch(connectivityProvider).when(
        data: (result) {
          if (result.isEmpty || result.contains(ConnectivityResult.none)) {
            return NetworkDisconnectedState();
          }

          return NetworkConnectedState(result: result);
        },
        loading: () => NetworkInitialState(),
        error: (_, __) => NetworkDisconnectedState(),
      );
});

class NetworkListener extends ConsumerWidget {
  const NetworkListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = ref.watch(loggerProvider);

    ref.listen(
      connectivityProvider,
      (previous, next) {
        next.when(
          data: (data) {
            if (data.isEmpty || data.contains(ConnectivityResult.none)) {
              logger.logW(_serviceName, 'Network disconnected');
            } else {
              logger.logI(
                _serviceName,
                'Connected to ${data.prettyString}',
              );
            }
          },
          error: (error, stackTrace) {
            logger.logE(
              _serviceName,
              'Error: $error',
            );
          },
          loading: () => logger.logI(_serviceName, 'Network connecting...'),
        );
      },
    );

    return child;
  }
}
