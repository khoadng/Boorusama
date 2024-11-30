import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:version/version.dart';

import '../backups/backups.dart';
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
