// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/clipboard.dart';
import '../../../foundation/display.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/toast.dart';
import '../../blacklists/providers.dart';
import '../../blacklists/src/types/blacklisted_tag.dart';
import '../../widgets/widgets.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kBlacklistedTagsBackupVersion = 1;

class BlacklistedTagsBackupSource
    extends JsonBackupSource<List<BlacklistedTag>> {
  BlacklistedTagsBackupSource(Ref ref)
    : super(
        id: 'blacklisted_tags',
        priority: 2,
        version: kBlacklistedTagsBackupVersion,
        appVersion: ref.read(appVersionProvider),
        dataGetter: () async {
          final tags = await ref.read(globalBlacklistedTagsProvider.future);
          return tags.unlock;
        },
        executor: (tags, _) async {
          final repo = await ref.read(globalBlacklistedTagRepoProvider.future);
          await repo.addTags(tags);
          ref.invalidate(globalBlacklistedTagsProvider);
        },
        handler: ListHandler<BlacklistedTag>(
          parser: BlacklistedTag.fromJson,
          encoder: (tag) => tag.toJson(),
        ),
        ref: ref,
      );

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
