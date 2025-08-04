// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/clipboard.dart';
import '../../../foundation/info/package_info.dart';
import '../../routers/routers.dart';
import '../../tags/favorites/src/providers/favorite_tags_notifier.dart';
import '../../tags/favorites/src/providers/providers.dart';
import '../../tags/favorites/src/types/favorite_tag.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kFavoriteTagsBackupVersion = 1;

class FavoriteTagsBackupSource extends JsonBackupSource<List<FavoriteTag>> {
  FavoriteTagsBackupSource(Ref ref)
    : super(
        id: 'favorite_tags',
        priority: 1,
        version: kFavoriteTagsBackupVersion,
        appVersion: ref.read(appVersionProvider),
        dataGetter: () async => ref.read(favoriteTagsProvider),
        executor: (tags, _) async {
          final repo = await ref.read(favoriteTagRepoProvider.future);
          await repo.createFrom(tags);
          ref.invalidate(favoriteTagsProvider);
        },
        handler: ListHandler<FavoriteTag>(
          parser: FavoriteTag.fromJson,
          encoder: (tag) => tag.toJson(),
        ),
        ref: ref,
      );

  @override
  String get displayName => 'Favorite tags';

  @override
  Widget buildTile(BuildContext context) {
    return DefaultBackupTile(
      source: this,
      title: 'Favorite tags',
      icon: Symbols.favorite,
      customActions: const {
        'export_simple': Text('Export (simple)'),
        'import_simple': Text('Import (simple)'),
      },
      onCustomAction: (context, ref, action) {
        if (action == 'export_simple') {
          ref
              .read(favoriteTagsProvider.notifier)
              .export(
                onDone: (tagString) {
                  AppClipboard.copyAndToast(
                    context,
                    tagString,
                    message: 'Favorite tags copied to clipboard',
                  );
                },
              );
        } else if (action == 'import_simple') {
          goToFavoriteTagImportPage(context);
        }
      },
    );
  }
}
