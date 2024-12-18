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

final localIPAddressProvider = FutureProvider<String?>((ref) async {
  // listen to changes in network state
  ref.listen(
    connectivityProvider,
    (previous, next) {
      // if the network state changes, we want to update the IP address
      ref.invalidateSelf();
    },
  );

  try {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      // Look for the WiFi or Ethernet interface
      if (interface.addresses.isNotEmpty) {
        // Filter for IPv4 addresses
        final ipv4 = interface.addresses.firstWhere(
          (addr) => addr.type == InternetAddressType.IPv4,
          orElse: () => interface.addresses.first,
        );
        // Skip loopback addresses (127.0.0.1)
        if (!ipv4.address.startsWith('127.')) {
          return ipv4.address;
        }
      }
    }
  } catch (e) {
    print('Error getting IP address: $e');
  }
  return '127.0.0.1'; // Fallback to localhost
});

class NetworkListener extends ConsumerWidget {
  const NetworkListener({
    super.key,
    required this.child,
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
