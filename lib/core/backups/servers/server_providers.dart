// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/networking/network_provider.dart';
import '../../blacklists/providers.dart';
import '../../bookmarks/bookmark.dart';
import '../../bookmarks/providers.dart';
import '../../bulk_downloads/providers.dart';
import '../../configs/export_import/types.dart';
import '../../configs/manage/providers.dart';
import '../../search/histories/providers.dart';
import '../../tags/favorites/providers.dart';
import '../db_transfer.dart';
import '../providers.dart';
import '../registry/backup_providers.dart';
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

  // Get categories from the new registry system
  final registryCategories = registry
      .getAllSources()
      .map(
        (source) => ExportCategory(
          name: source.id,
          displayName: source.displayName,
          route: source.id,
          handler: (request) async {
            try {
              return await source.serveData(request);
            } catch (error) {
              return Response.internalServerError(body: error.toString());
            }
          },
        ),
      )
      .toList();

  // Legacy hardcoded sources (remove as they're migrated)
  final legacyCategories = [
    ExportCategory(
      name: 'favorite_tags',
      displayName: 'Favorite tags',
      route: 'favorite_tags',
      handler: (request) async {
        try {
          final value = await ref
              .read(favoriteTagsProvider.notifier)
              .exportWithLabelsToRawString();

          return Response.ok(value);
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
    ExportCategory(
      name: 'booru_configs',
      displayName: 'Booru profiles',
      route: 'configs',
      handler: (request) async {
        try {
          final repo = ref.read(booruConfigRepoProvider);
          final configs = await repo.getAll();
          final converter = ref.read(
            defaultBackupConverterProvider(
              kBooruConfigsExporterImporterVersion,
            ),
          );
          final result = converter.tryEncode(payload: configs);

          return result.fold(
            (error) => Response.internalServerError(body: error.toString()),
            (json) => Response.ok(json),
          );
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
    ExportCategory(
      name: 'blacklisted_tags',
      displayName: 'Blacklisted tags',
      route: 'blacklisted_tags',
      handler: (request) async {
        try {
          final blacklistedTags = ref.read(
            globalBlacklistedTagsProvider.future,
          );
          final tags = (await blacklistedTags).map((e) => e.name).join('\n');
          final map = {'tags': tags};

          return Response.ok(jsonEncode(map));
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
    ExportCategory(
      name: 'bookmarks',
      displayName: 'Bookmarks',
      route: 'bookmarks',
      handler: (request) async {
        try {
          final bookmarks = await (await ref.read(bookmarkRepoProvider.future))
              .getAllBookmarksOrEmpty(
                imageUrlResolver: (booruId) =>
                    ref.read(bookmarkUrlResolverProvider(booruId)),
              );
          final json = bookmarks.map((bookmark) => bookmark.toJson()).toList();
          final jsonString = jsonEncode(json);

          return Response.ok(jsonString);
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
    ExportCategory(
      name: 'search_histories',
      displayName: 'Search histories',
      route: 'search_histories',
      handler: (request) async {
        try {
          final dbPath = await getSearchHistoryDbPath();

          return await createDbStreamResponse(
            filePath: dbPath,
            fileName: kSearchHistoryDbName,
          );
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
    ExportCategory(
      name: 'downloads',
      displayName: 'Downloads',
      route: 'downloads',
      handler: (request) async {
        try {
          final dbPath = await getDownloadsDbPath();

          return await createDbStreamResponse(
            filePath: dbPath,
            fileName: kDownloadDbName,
          );
        } catch (e) {
          return Response.internalServerError(body: e.toString());
        }
      },
    ),
  ];

  // Filter out legacy categories that have been migrated to registry
  final filteredLegacyCategories = legacyCategories
      .where((legacy) => !registry.hasSource(legacy.name))
      .toList();

  return [...registryCategories, ...filteredLegacyCategories];
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
      'health': (request) async => Response(204),
      for (final category in categories) category.route: category.handler,
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
