// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/networking/networking.dart';

const _serviceName = 'Connectivity';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final logger = ref.watch(loggerProvider);
  final analytics = ref.watch(analyticsProvider);

  ref.listenSelf(
    (previous, next) {
      next.when(
        data: (data) {
          if (data.isEmpty || data.contains(ConnectivityResult.none)) {
            analytics.updateNetworkInfo(
              const AnalyticsNetworkInfo.disconnected(),
            );
            logger.logW(_serviceName, 'Network disconnected');
          } else {
            analytics.updateNetworkInfo(
              AnalyticsNetworkInfo.connected(data.prettyString),
            );
            logger.logI(
              _serviceName,
              'Connected to ${data.prettyString}',
            );
          }
        },
        error: (error, stackTrace) {
          analytics.updateNetworkInfo(
            AnalyticsNetworkInfo.error(error.toString()),
          );

          logger.logE(
            _serviceName,
            'Error: $error',
          );
        },
        loading: () => logger.logI(_serviceName, 'Network connecting...'),
      );
    },
  );

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
        loading: () => NetworkDisconnectedState(),
        error: (_, __) => NetworkDisconnectedState(),
      );
});
