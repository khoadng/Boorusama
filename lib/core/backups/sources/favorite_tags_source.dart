// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../../foundation/clipboard.dart';
import '../../../foundation/info/package_info.dart';
import '../../routers/routers.dart';
import '../../tags/favorites/providers.dart';
import '../../tags/favorites/types.dart';
import '../sync/strategies/favorite_tag_merge.dart';
import '../sync/types.dart';
import '../types/backup_data_source.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kFavoriteTagsBackupVersion = 1;

class FavoriteTagsBackupSource extends JsonBackupSource<List<FavoriteTag>> {
  FavoriteTagsBackupSource(this._ref)
    : super(
        id: 'favorite_tags',
        priority: 1,
        version: kFavoriteTagsBackupVersion,
        appVersion: _ref.read(appVersionProvider),
        dataGetter: () async => _ref.read(favoriteTagsProvider),
        executor: (tags, _) async {
          final repo = await _ref.read(favoriteTagRepoProvider.future);
          await repo.createFrom(tags);
          _ref.invalidate(favoriteTagsProvider);
        },
        handler: ListHandler<FavoriteTag>(
          parser: FavoriteTag.fromJson,
          encoder: (tag) => tag.toJson(),
        ),
        ref: _ref,
      );

  final Ref _ref;
  final _mergeStrategy = FavoriteTagMergeStrategy();

  @override
  SyncCapability<FavoriteTag> get syncCapability => SyncCapability<FavoriteTag>(
    mergeStrategy: _mergeStrategy,
    handlePush: _handlePush,
    getUniqueIdFromJson: _mergeStrategy.getUniqueIdFromJson,
    importResolved: _importResolved,
  );

  Future<void> _importResolved(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;

    final resolvedTags = data.map((e) => FavoriteTag.fromJson(e)).toList();

    final repo = await _ref.read(favoriteTagRepoProvider.future);
    await repo.createFrom(resolvedTags);
    _ref.invalidate(favoriteTagsProvider);
  }

  Future<SyncStats> _handlePush(shelf.Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);

    final remoteData = switch (json) {
      {'data': final List<dynamic> data} => data,
      final List<dynamic> data => data,
      _ => <dynamic>[],
    };

    final remoteItems = remoteData
        .map((e) => FavoriteTag.fromJson(e as Map<String, dynamic>))
        .toList();
    final localItems = await dataGetter();
    final result = _mergeStrategy.merge(localItems, remoteItems);

    final repo = await _ref.read(favoriteTagRepoProvider.future);
    await repo.createFrom(result.merged);
    _ref.invalidate(favoriteTagsProvider);

    return result.stats;
  }

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
