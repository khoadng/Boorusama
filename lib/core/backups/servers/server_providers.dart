// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/networking/network_provider.dart';
import '../sources/providers.dart';
import 'server.dart';

class ExportCategory {
  const ExportCategory({
    required this.name,
    required this.displayName,
    required this.route,
    required this.handler,
  });

  final String displayName;
  final String name;
  final String route;
  final Handler handler;
}

final exportCategoriesProvider = Provider<List<ExportCategory>>((ref) {
  // Ensure all backup sources are registered
  ref.watch(allBackupSourcesProvider);

  final registry = ref.watch(backupRegistryProvider);

  // Get categories from the registry system
  final registryCategories = registry
      .getAllSources()
      .map(
        (source) => ExportCategory(
          name: source.id,
          displayName: source.displayName,
          route: source.id,
          handler: source.capabilities.server.export,
        ),
      )
      .toList();

  return registryCategories;
});

final dataSyncServerProvider = Provider<AppServer>((ref) {
  final registry = ref.watch(backupRegistryProvider);

  final server = AppServer(
    logger: ref.watch(loggerProvider),
    serverName: ref.watch(deviceInfoProvider).deviceName ?? 'Unknown server',
    appVersion: ref.watch(packageInfoProvider).version,
    onError: (message) {
      ref.read(loggerProvider).error('DataSyncServer', message);
    },
    routes: {
      'health': (request) => Response(204),
      for (final source in registry.getAllSources())
        source.id: source.capabilities.server.export,
    },
  );

  // Wifi is required since our transfer protocol is within the local network.
  ref
    ..listen(
      connectedToWifiProvider,
      (previous, next) {
        if (next != previous) {
          if (next) {
            server.dispose();
          }
        }
      },
    )
    ..onDispose(server.dispose);

  return server;
});
