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
import '../../settings/providers.dart';
import '../../tags/favorites/providers.dart';
import '../db_transfer.dart';
import '../providers.dart';
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
    ExportCategory(
      name: 'settings',
      displayName: 'Settings',
      route: 'settings',
      handler: (request) async {
        final settings = ref.read(settingsProvider);

        return Response.ok(jsonEncode(settings.toJson()));
      },
    ),
    ExportCategory(
      name: 'blacklisted_tags',
      displayName: 'Blacklisted tags',
      route: 'blacklisted_tags',
      handler: (request) async {
        final blacklistedTags = ref.read(globalBlacklistedTagsProvider.future);
        final tags = (await blacklistedTags).map((e) => e.name).join('\n');
        final map = {'tags': tags};

        return Response.ok(jsonEncode(map));
      },
    ),
    ExportCategory(
      name: 'bookmarks',
      displayName: 'Bookmarks',
      route: 'bookmarks',
      handler: (request) async {
        final bookmarks = await (await ref.read(bookmarkRepoProvider.future))
            .getAllBookmarksOrEmpty(
              imageUrlResolver: (booruId) =>
                  ref.read(bookmarkUrlResolverProvider(booruId)),
            );
        final json = bookmarks.map((bookmark) => bookmark.toJson()).toList();
        final jsonString = jsonEncode(json);

        return Response.ok(jsonString);
      },
    ),
    ExportCategory(
      name: 'search_histories',
      displayName: 'Search histories',
      route: 'search_histories',
      handler: (request) async {
        final dbPath = await getSearchHistoryDbPath();

        return createDbStreamResponse(
          filePath: dbPath,
          fileName: kSearchHistoryDbName,
        );
      },
    ),
    ExportCategory(
      name: 'downloads',
      displayName: 'Downloads',
      route: 'downloads',
      handler: (request) async {
        final dbPath = await getDownloadsDbPath();

        return createDbStreamResponse(
          filePath: dbPath,
          fileName: kDownloadDbName,
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
