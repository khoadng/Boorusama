// Dart imports:
import 'dart:io';

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
  return ref
      .watch(connectivityProvider)
      .when(
        data: (result) {
          if (result.isEmpty || result.contains(ConnectivityResult.none)) {
            return NetworkDisconnectedState();
          }

          return NetworkConnectedState(result: result);
        },
        loading: () => NetworkInitialState(),
        error: (_, _) => NetworkDisconnectedState(),
      );
});

final localIPAddressProvider = FutureProvider.autoDispose<String?>((ref) async {
  final logger = ref.watch(loggerProvider);
  final connectivityResult = await ref.watch(connectivityProvider.future);

  // listen to changes in network state
  ref.listen(
    connectivityProvider,
    (previous, next) {
      // if the network state changes, we want to update the IP address
      ref.invalidateSelf();
    },
  );

  // If WiFi isn't active, return immediately.
  if (!connectivityResult.contains(ConnectivityResult.wifi)) {
    logger.logW(_serviceName, 'Not connected to WiFi');
    return null;
  }

  try {
    final interfaces = await NetworkInterface.list();

    // Filter out interfaces with loopback addresses or those that likely represent cellular.
    final candidates = interfaces.where((interface) {
      // Skip if any address is loopback.
      if (interface.addresses.any((addr) => addr.address.startsWith('127.'))) {
        return false;
      }
      // Heuristic for cellular interfaces.
      final lowerName = interface.name.toLowerCase();
      if (lowerName.contains('rmnet') || lowerName.contains('pdp_ip')) {
        return false;
      }

      return true;
    }).toList();

    if (candidates.isEmpty) {
      logger.logW(
        _serviceName,
        'No valid network interfaces found.',
      );
      return null;
    }

    // When WiFi is active, try to prefer an interface with "wlan" in its name.
    final selectedInterface = candidates.firstWhere(
      (interface) => interface.name.toLowerCase().contains('wlan'),
      orElse: () => candidates.first,
    );

    // Pick an IPv4 address from the chosen interface.
    final ipv4 = selectedInterface.addresses.firstWhere(
      (addr) => addr.type == InternetAddressType.IPv4,
      orElse: () => selectedInterface.addresses.first,
    );

    return ipv4.address;
  } catch (e) {
    logger.logE(_serviceName, 'Error getting IP address: $e');
  }

  logger.logW(_serviceName, 'Failed to get local IP address.');

  return null;
});

final connectedToWifiProvider = Provider<bool>((ref) {
  final connectivityResult = ref.watch(connectivityProvider);

  return connectivityResult.when(
    data: (data) => data.contains(ConnectivityResult.wifi),
    loading: () => false,
    error: (_, _) => false,
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
