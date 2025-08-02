// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/picker.dart';
import '../../../../../foundation/toast.dart';
import '../../settings/src/pages/backup_restore/backup_restore_tile.dart';
import '../../widgets/widgets.dart';
import '../registry/backup_data_source.dart';
import '../registry/backup_providers.dart';

class BackupSourceTile extends ConsumerWidget {
  const BackupSourceTile({
    required this.sourceId,
    super.key,
  });

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(backupRegistryProvider);
    final source = registry.getSource(sourceId);

    if (source == null) {
      return const SizedBox.shrink();
    }

    final config = source.uiConfig;

    return BackupRestoreTile(
      leadingIcon: config.icon,
      title: source.displayName,
      subtitle: config.subtitle,
      extra: config.extraWidget != null
          ? [
              const SizedBox(height: 8),
              config.extraWidget!,
              const SizedBox(height: 8),
            ]
          : null,
      trailing: BooruPopupMenuButton(
        onSelected: (value) => _handleAction(context, ref, source, value),
        itemBuilder: {
          for (final action in config.actions.where((a) => a.enabled))
            action.type.name: Text(action.label),
        },
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    BackupDataSource source,
    String actionType,
  ) {
    switch (actionType) {
      case 'export':
        _handleExport(context, source);
      case 'import':
        _handleImport(context, source);
      case 'exportClipboard':
        _handleExportClipboard(context, source);
      case 'importClipboard':
        _handleImportClipboard(context, source);
    }
  }

  void _handleExport(BuildContext context, BackupDataSource source) {
    pickDirectoryPathToastOnError(
      context: context,
      onPick: (path) async {
        final result = await source.exportToDirectory(path);

        if (context.mounted) {
          result.fold(
            (error) => showErrorToast(
              context,
              'Failed to export ${source.displayName.toLowerCase()}: ${error.message}',
            ),
            (_) => showSuccessToast(
              context,
              '${source.displayName} exported successfully',
            ),
          );
        }
      },
    );
  }

  void _handleImport(BuildContext context, BackupDataSource source) {
    pickSingleFilePathToastOnError(
      context: context,
      type: FileType.custom,
      allowedExtensions: ['json'],
      onPick: (path) async {
        final result = await source.importFromFile(path);

        if (context.mounted) {
          result.fold(
            (error) => showErrorToast(
              context,
              'Failed to import ${source.displayName.toLowerCase()}: ${error.message}',
            ),
            (_) => showSuccessToast(
              context,
              '${source.displayName} imported successfully',
            ),
          );
        }
      },
    );
  }

  Future<void> _handleExportClipboard(
    BuildContext context,
    BackupDataSource source,
  ) async {
    final result = await source.exportToClipboard();

    if (context.mounted) {
      result.fold(
        (error) => showErrorToast(
          context,
          'Failed to copy ${source.displayName.toLowerCase()}: ${error.message}',
        ),
        (_) => showSuccessToast(
          context,
          '${source.displayName} copied to clipboard',
        ),
      );
    }
  }

  Future<void> _handleImportClipboard(
    BuildContext context,
    BackupDataSource source,
  ) async {
    final result = await source.importFromClipboard();

    if (context.mounted) {
      result.fold(
        (error) => showErrorToast(
          context,
          'Failed to paste ${source.displayName.toLowerCase()}: ${error.message}',
        ),
        (_) => showSuccessToast(
          context,
          '${source.displayName} imported from clipboard',
        ),
      );
    }
  }
}
