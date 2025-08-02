// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/info/package_info.dart';
import '../../../../../foundation/picker.dart';
import '../../../../../foundation/toast.dart';
import '../../../../../foundation/version.dart';
import '../../../foundation/clipboard.dart';
import '../../settings/src/pages/backup_restore/backup_restore_tile.dart';
import '../../widgets/widgets.dart';
import '../import/backward_import_alert_dialog.dart';
import '../import/version_mismatch_alert_dialog.dart';
import '../registry/backup_data_source.dart';
import '../registry/backup_providers.dart';
import '../types.dart';

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
        _handleImport(context, ref, source);
      case 'exportClipboard':
        _handleExportClipboard(context, source);
      case 'importClipboard':
        _handleImportClipboard(context, ref, source);
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

  void _handleImport(
    BuildContext context,
    WidgetRef ref,
    BackupDataSource source,
  ) {
    pickSingleFilePathToastOnError(
      context: context,
      type: FileType.custom,
      allowedExtensions: ['json'],
      onPick: (path) async {
        final result = await _importWithVersionCheck(
          context,
          ref,
          source,
          path,
        );

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
    WidgetRef ref,
    BackupDataSource source,
  ) async {
    final result = await _importFromClipboardWithVersionCheck(
      context,
      ref,
      source,
    );

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

  Future<Either<ImportError, Unit>> _importWithVersionCheck(
    BuildContext context,
    WidgetRef ref,
    BackupDataSource source,
    String path,
  ) async {
    // First, read and parse the file to check version
    final readResult = await source.parseImportData(
      await _readFile(path),
    );

    return readResult.fold(
      (error) => left(error),
      (exportData) async {
        final shouldImport = await _checkVersionCompatibility(
          context,
          ref,
          exportData,
        );

        if (!shouldImport) {
          return left(const ImportInvalidJson());
        }

        return source.importFromFile(path);
      },
    );
  }

  Future<Either<ImportError, Unit>> _importFromClipboardWithVersionCheck(
    BuildContext context,
    WidgetRef ref,
    BackupDataSource source,
  ) async {
    // Get clipboard content
    final clipboardContent = await _getClipboardContent();
    if (clipboardContent.isEmpty) {
      return left(const ImportErrorEmpty());
    }

    // Parse to check version
    final parseResult = await source.parseImportData(clipboardContent);

    return parseResult.fold(
      (error) => left(error),
      (exportData) async {
        final shouldImport = await _checkVersionCompatibility(
          context,
          ref,
          exportData,
        );

        if (!shouldImport) {
          return left(const ImportInvalidJson());
        }

        return source.importFromClipboard();
      },
    );
  }

  Future<bool> _checkVersionCompatibility(
    BuildContext context,
    WidgetRef ref,
    ExportDataPayload exportData,
  ) async {
    final currentVersion = ref.read(appVersionProvider);

    if (currentVersion == null || exportData.exportVersion == null) {
      return true; // Skip version checking if versions unavailable
    }

    final exportVersion = exportData.exportVersion!;

    // Check for backward compatibility issues
    if (currentVersion.significantlyLowerThan(exportVersion)) {
      final result = await showBackwardImportAlertDialog(
        context: context,
        data: exportData,
      );
      return result ?? false;
    }

    // Check for version mismatches
    if (currentVersion.significantlyHigherThan(exportVersion) ||
        currentVersion.significantlyLowerThan(exportVersion)) {
      final result = await showVersionMismatchAlertDialog(
        context: context,
        importVersion: exportVersion,
        currentVersion: currentVersion,
      );
      return result ?? false;
    }

    return true;
  }

  Future<String> _readFile(String path) async {
    final file = File(path);
    return file.readAsString();
  }

  Future<String> _getClipboardContent() async {
    final content = await AppClipboard.paste('text/plain');
    return content ?? '';
  }
}
