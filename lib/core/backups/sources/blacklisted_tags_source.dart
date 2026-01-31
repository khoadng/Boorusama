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
import '../../../foundation/display.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/toast.dart';
import '../../blacklists/providers.dart';
import '../../blacklists/types.dart';
import '../../widgets/widgets.dart';
import '../sync/strategies/blacklisted_tag_merge.dart';
import '../sync/types.dart';
import '../types/backup_data_source.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kBlacklistedTagsBackupVersion = 1;

class BlacklistedTagsBackupSource
    extends JsonBackupSource<List<BlacklistedTag>> {
  BlacklistedTagsBackupSource(this._ref)
    : super(
        id: 'blacklisted_tags',
        priority: 2,
        version: kBlacklistedTagsBackupVersion,
        appVersion: _ref.read(appVersionProvider),
        dataGetter: () async {
          final tags = await _ref.read(globalBlacklistedTagsProvider.future);
          return tags.unlock;
        },
        executor: (tags, _) async {
          final repo = await _ref.read(globalBlacklistedTagRepoProvider.future);
          await repo.addTags(tags);
          _ref.invalidate(globalBlacklistedTagsProvider);
        },
        handler: ListHandler<BlacklistedTag>(
          parser: BlacklistedTag.fromJson,
          encoder: (tag) => tag.toJson(),
        ),
        ref: _ref,
      );

  final Ref _ref;
  final _mergeStrategy = BlacklistedTagMergeStrategy();

  @override
  SyncCapability<BlacklistedTag> get syncCapability =>
      SyncCapability<BlacklistedTag>(
        mergeStrategy: _mergeStrategy,
        handlePush: _handlePush,
        getUniqueIdFromJson: _mergeStrategy.getUniqueIdFromJson,
        importResolved: _importResolved,
      );

  Future<void> _importResolved(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;

    final repo = await _ref.read(globalBlacklistedTagRepoProvider.future);
    final localTags = await dataGetter();

    final resolvedTags = data.map((e) => BlacklistedTag.fromJson(e)).toList();

    // Find local tags that will be replaced (same name)
    final resolvedNames = resolvedTags.map((t) => t.name).toSet();
    final toRemove = localTags.where((t) => resolvedNames.contains(t.name));

    // Remove existing tags that match resolved names
    for (final tag in toRemove) {
      await repo.removeTag(tag.id);
    }

    // Add all resolved tags
    await repo.addTags(resolvedTags);
    _ref.invalidate(globalBlacklistedTagsProvider);
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
        .map((e) => BlacklistedTag.fromJson(e as Map<String, dynamic>))
        .toList();
    final localItems = await dataGetter();
    final result = _mergeStrategy.merge(localItems, remoteItems);

    final newItems = result.merged
        .where((item) => !localItems.any((l) => l.name == item.name))
        .toList();

    if (newItems.isNotEmpty) {
      final repo = await _ref.read(globalBlacklistedTagRepoProvider.future);
      await repo.addTags(newItems);
      _ref.invalidate(globalBlacklistedTagsProvider);
    }

    return result.stats;
  }

  @override
  String get displayName => 'Blacklisted tags';

  @override
  Widget buildTile(BuildContext context) {
    return DefaultBackupTile(
      source: this,
      title: 'Blacklisted tags',
      icon: Symbols.block,
      customActions: const {
        'export_simple': Text('Export (simple)'),
        'import_simple': Text('Import (simple)'),
      },
      onCustomAction: (context, ref, action) {
        if (action == 'export_simple') {
          _exportSimple(context, ref);
        } else if (action == 'import_simple') {
          _importSimple(context, ref);
        }
      },
    );
  }

  Future<void> _exportSimple(BuildContext context, WidgetRef ref) async {
    try {
      final tags = await ref.read(globalBlacklistedTagsProvider.future);
      final tagString = tags.map((e) => e.name).join('\n');

      await AppClipboard.copy(tagString);
      if (context.mounted) {
        showSuccessToast(
          context,
          'Blacklisted tags copied to clipboard',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorToast(
          context,
          'Failed to export blacklisted tags: $e',
        );
      }
    }
  }

  void _importSimple(BuildContext context, WidgetRef ref) {
    const hint =
        'Each rule goes on a separate line:\n\nlong_hair score:<0\nblonde_hair';

    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, _) => ImportTagsDialog(
        padding: kPreferredLayout.isMobile ? 0 : 8,
        hint: hint,
        onImport: (tagString, _) {
          ref
              .read(globalBlacklistedTagsProvider.notifier)
              .addTagStringWithToast(context, tagString);
        },
      ),
    );
  }
}
