// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:version/version.dart';

// Project imports:
import '../backups/data_converter.dart';
import '../configs/manage.dart';
import '../configs/src/export_import/booru_config_io_handler.dart';
import '../foundation/loggers.dart';
import '../info/package_info.dart';
import '../tags/favorites/providers.dart';
import 'servers.dart';

final dataSyncServerProvider = Provider<AppServer>((ref) {
  final server = AppServer(
    onError: (message) {
      ref.read(loggerProvider).logE('DataSyncServer', message);
    },
    routes: {
      // 'blacklist': (request) async {
      //   final repo = ref.read(globalBlacklistedTagRepoProvider);
      //   final blacklist = await repo.getBlacklist();
      //   final blacklistString = blacklist.map((tag) => tag.name).join('\n');
      //   return Response.ok(blacklistString);
      // },
      'favorite_tags': (request) async {
        final value = await ref
            .read(favoriteTagsProvider.notifier)
            .exportWithLabelsToRawString();

        return Response.ok(value);
      },
      'configs': (request) async {
        final repo = ref.read(booruConfigRepoProvider);
        final packageInfo = ref.read(packageInfoProvider);
        final configs = await repo.getAll();
        final result = tryEncodeData(
          version: kBooruConfigsExporterImporterVersion,
          exportDate: DateTime.now(),
          payload: configs,
          exportVersion: Version.parse(packageInfo.version),
        );

        return result.fold(
          (l) => Response.internalServerError(body: l.toString()),
          (r) => Response.ok(r),
        );
      },
    },
  );

  ref.onDispose(server.dispose);

  return server;
});
