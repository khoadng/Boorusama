// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../backups/providers.dart';
import '../configs/manage.dart';
import '../configs/src/export_import/booru_config_io_handler.dart';
import '../foundation/loggers.dart';
import '../info/device_info.dart';
import '../info/package_info.dart';
import '../tags/favorites/providers.dart';
import 'servers.dart';

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
  return [
    ExportCategory(
      name: 'favorite_tags',
      displayName: 'Favorite tags',
      route: 'favorite_tags',
      handler: (request) async {
        final value = await ref
            .read(favoriteTagsProvider.notifier)
            .exportWithLabelsToRawString();

        return Response.ok(value);
      },
    ),
    ExportCategory(
      name: 'booru_configs',
      displayName: 'Booru profiles',
      route: 'configs',
      handler: (request) async {
        final repo = ref.read(booruConfigRepoProvider);
        final configs = await repo.getAll();
        final converter = ref.read(
          defaultBackupConverterProvider(
            kBooruConfigsExporterImporterVersion,
          ),
        );
        final result = converter.tryEncode(payload: configs);

        return result.fold(
          (l) => Response.internalServerError(body: l.toString()),
          (r) => Response.ok(r),
        );
      },
    ),
  ];
});

final dataSyncServerProvider = Provider<AppServer>((ref) {
  final categories = ref.watch(exportCategoriesProvider);

  final server = AppServer(
    logger: ref.watch(loggerProvider),
    serverName: ref.watch(deviceInfoProvider).deviceName ?? 'Unknown server',
    appVersion: ref.watch(packageInfoProvider).version,
    onError: (message) {
      ref.read(loggerProvider).logE('DataSyncServer', message);
    },
    routes: {
      for (final category in categories) category.route: category.handler,
    },
  );

  ref.onDispose(server.dispose);

  return server;
});
