// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/picker.dart';
import '../../../foundation/toast.dart';
import '../../settings/providers.dart';
import '../auto/providers.dart';
import '../auto/types.dart';
import '../sources/providers.dart';
import '../utils/backup_file_picker.dart';
import 'bulk_backup_service.dart';
import 'types.dart';
import 'zip_preview_dialog.dart';

enum BackupStatus {
  idle,
  exporting,
  importing,
  completed,
  error,
}

class BackupState extends Equatable {
  const BackupState({
    required this.status,
    this.progress = 0.0,
    this.exportResult,
    this.importResult,
    this.error,
  });

  final BackupStatus status;
  final double progress;
  final BulkExportResult? exportResult;
  final BulkImportResult? importResult;
  final String? error;

  bool get isActive =>
      status == BackupStatus.exporting || status == BackupStatus.importing;

  BackupState copyWith({
    BackupStatus? status,
    double? progress,
    BulkExportResult? exportResult,
    BulkImportResult? importResult,
    String? error,
  }) {
    return BackupState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      exportResult: exportResult ?? this.exportResult,
      importResult: importResult ?? this.importResult,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    progress,
    exportResult,
    importResult,
    error,
  ];
}

final backupProvider =
    NotifierProvider.autoDispose<BackupNotifier, BackupState>(
      BackupNotifier.new,
    );

class BackupNotifier extends AutoDisposeNotifier<BackupState> {
  @override
  BackupState build() {
    return const BackupState(status: BackupStatus.idle);
  }

  // Manual export operations
  Future<void> exportAll(BuildContext context) {
    final registry = ref.read(backupRegistryProvider);
    final allSourceIds = registry.getAllSources().map((s) => s.id).toList();
    return exportToZip(context, allSourceIds);
  }

  Future<void> exportToZip(BuildContext context, List<String> sourceIds) async {
    final logger = ref.read(loggerProvider);
    final platform = Theme.of(context).platform;

    if (state.isActive) {
      logger.warn(
        'Backup.UI',
        'Export requested but backup already in progress',
      );
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.backup_in_progress,
      );
      return;
    }

    logger.verbose(
      'Backup.UI',
      'Starting export for ${sourceIds.length} sources: ${sourceIds.join(', ')}',
    );

    try {
      state = state.copyWith(
        status: BackupStatus.exporting,
        progress: 0,
      );

      final path = await _pickExportDirectory(context);
      if (path == null) {
        logger.info('Backup.UI', 'Export cancelled - no directory selected');
        state = state.copyWith(status: BackupStatus.idle);
        return;
      }

      logger.verbose('Backup.UI', 'Exporting to directory: $path');

      final service = ref.read(bulkBackupServiceProvider);
      final result = await service.exportToZip(
        path,
        sourceIds,
        onProgress: (progress) {
          state = state.copyWith(progress: progress.progress);
        },
      );

      state = state.copyWith(
        status: BackupStatus.completed,
        exportResult: result,
        progress: 1,
      );

      logger.verbose(
        'Backup.UI',
        'Export completed: ${result.exported.length} exported, ${result.failed.length} failed',
      );

      if (context.mounted) {
        _showExportResult(context, result);
      }
    } on Exception catch (e) {
      final errorMessage = switch ((
        isPathException: _isPathAccessException(e),
        mounted: context.mounted,
        platform: platform,
      )) {
        (
          isPathException: true,
          mounted: true,
          platform: TargetPlatform.android,
        ) =>
          // ignore: use_build_context_synchronously
          context.t.settings.backup_and_restore.invalid_location_error,
        _ => e.toString(),
      };

      logger.error('Backup.UI', 'Export failed: $errorMessage');

      state = state.copyWith(
        status: BackupStatus.error,
        error: errorMessage,
      );

      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.export_operation_failed
              .replaceAll('{error}', errorMessage),
        );
      }
    }
  }

  Future<void> importFromZip(
    BuildContext context, {
    List<String>? onlySourceIds,
  }) async {
    final logger = ref.read(loggerProvider);

    if (state.isActive) {
      logger.warn(
        'Backup.UI',
        'Import requested but backup already in progress',
      );
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.backup_in_progress,
      );
      return;
    }

    final sourceFilter = onlySourceIds != null
        ? 'filtering for ${onlySourceIds.join(', ')}'
        : 'all sources';
    logger.verbose('Backup.UI', 'Starting import with preview - $sourceFilter');

    try {
      await BackupFilePicker.pickFile(
        context: context,
        androidDeviceInfo: ref.read(deviceInfoProvider).androidDeviceInfo,
        allowedExtensions: ['zip'],
        onPick: (path) async {
          await _importWithPreview(context, path, onlySourceIds);
        },
      );
    } catch (e) {
      logger.error('Backup.UI', 'Import failed: $e');

      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.import_operation_failed
              .replaceAll('{error}', e.toString()),
        );
      }
    }
  }

  Future<void> _importWithPreview(
    BuildContext context,
    String zipPath,
    List<String>? onlySourceIds,
  ) async {
    final logger = ref.read(loggerProvider);

    try {
      logger.verbose('Backup.UI', 'Previewing zip: $zipPath');

      // Show loading state for preview
      state = state.copyWith(
        status: BackupStatus.importing,
        progress: 0,
      );

      final service = ref.read(bulkBackupServiceProvider);
      final previewResult = await service.previewZip(zipPath);

      // Reset state after preview
      state = state.copyWith(status: BackupStatus.idle);

      if (!context.mounted) return;

      // Show preview dialog
      final selectedSourceIds = await showZipPreviewDialog(
        context,
        previewResult,
      );

      if (selectedSourceIds == null || selectedSourceIds.isEmpty) {
        logger.info('Backup.UI', 'Import cancelled or no sources selected');
        return;
      }

      // Filter selected sources if onlySourceIds was specified
      final finalSourceIds = onlySourceIds != null
          ? selectedSourceIds.where((id) => onlySourceIds.contains(id)).toList()
          : selectedSourceIds;

      if (finalSourceIds.isEmpty) {
        logger.verbose('Backup.UI', 'No matching sources selected for import');
        if (context.mounted) {
          showErrorToast(
            context,
            'No selected sources match the requested filter',
          );
        }
        return;
      }

      logger.verbose(
        'Backup.UI',
        'Proceeding with import for sources: ${finalSourceIds.join(', ')}',
      );

      // Proceed with actual import
      state = state.copyWith(
        status: BackupStatus.importing,
        progress: 0,
      );

      if (!context.mounted) return;

      final result = await service.importFromZip(
        zipPath,
        context,
        onlySourceIds: finalSourceIds,
      );

      state = state.copyWith(
        status: BackupStatus.completed,
        importResult: result,
        progress: 1,
      );

      logger.verbose(
        'Backup.UI',
        'Import completed: ${result.imported.length} imported, ${result.failed.length} failed, ${result.skipped.length} skipped',
      );

      if (context.mounted) {
        _showImportResult(context, result);
      }
    } catch (e) {
      logger.error('Backup.UI', 'Import failed: $e');

      state = state.copyWith(
        status: BackupStatus.error,
        error: e.toString(),
      );

      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.import_operation_failed
              .replaceAll('{error}', e.toString()),
        );
      }
    }
  }

  // Auto backup operations
  Future<void> performAutoBackupIfNeeded(AutoBackupSettings settings) async {
    final logger = ref.read(loggerProvider);

    if (state.isActive) {
      logger.warn(
        'Backup.Auto',
        'Auto backup skipped - backup already in progress',
      );
      return;
    }

    if (!settings.shouldBackup) {
      logger.verbose('Backup.Auto', 'Auto backup skipped - conditions not met');
      return;
    }

    logger.verbose('Backup.Auto', 'Starting automatic backup');
    await _performAutoBackup(settings, isManual: false);
  }

  Future<void> performManualAutoBackup(AutoBackupSettings settings) async {
    final logger = ref.read(loggerProvider);

    if (state.isActive) {
      logger.warn(
        'Backup.Auto',
        'Manual auto backup skipped - backup already in progress',
      );
      return;
    }

    logger.verbose('Backup.Auto', 'Starting manual auto backup');
    await _performAutoBackup(settings, isManual: true);
  }

  Future<void> _performAutoBackup(
    AutoBackupSettings settings, {
    required bool isManual,
  }) async {
    final logger = ref.read(loggerProvider);

    final startTime = DateTime.now();
    final backupType = isManual ? 'manual auto' : 'automatic';

    logger.verbose('Backup.Auto', 'Performing $backupType backup');

    try {
      state = state.copyWith(
        status: BackupStatus.exporting,
        progress: 0,
      );

      final autoBackupService = ref.read(autoBackupServiceProvider);
      final result = await autoBackupService.performBackup(
        settings,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );

      if (result.success) {
        logger.verbose(
          'Backup.Auto',
          'Auto backup completed successfully - updating last backup time',
        );

        // Update settings after successful backup
        await ref
            .read(settingsNotifierProvider.notifier)
            .updateWith(
              (s) => s.copyWith(
                autoBackup: settings.copyWith(
                  lastBackupTime: () => DateTime.now(),
                ),
              ),
            );
      } else {
        logger.warn(
          'Backup.Auto',
          'Auto backup completed but with no success',
        );
      }

      state = state.copyWith(
        status: BackupStatus.completed,
        exportResult: result,
        progress: 1,
      );
    } catch (e) {
      logger.error('Backup.Auto', 'Auto backup failed: $e');

      state = state.copyWith(
        status: BackupStatus.error,
        error: e.toString(),
      );
    } finally {
      // Ensure minimum 1s duration for better UX
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(
          Duration(milliseconds: 1000 - elapsed.inMilliseconds),
        );
      }

      final duration = DateTime.now().difference(startTime);
      logger.verbose(
        'Backup.Auto',
        'Auto backup process completed in ${duration.inMilliseconds}ms',
      );
    }
  }

  void reset() {
    state = const BackupState(status: BackupStatus.idle);
  }

  Future<String?> _pickExportDirectory(BuildContext context) async {
    String? selectedPath;

    await pickDirectoryPathToastOnError(
      context: context,
      onPick: (path) {
        selectedPath = path;
      },
    );

    return selectedPath;
  }

  void _showExportResult(BuildContext context, BulkExportResult result) {
    if (result.success) {
      final message = result.hasFailures
          ? context.t.settings.backup_and_restore.export_partial_success
                .replaceAll('{exported}', result.exported.length.toString())
                .replaceAll('{total}', result.totalSources.toString())
                .replaceAll('{failed}', result.failed.length.toString())
          : context.t.settings.backup_and_restore.export_complete_success
                .replaceAll('{exported}', result.exported.length.toString());

      showSuccessToast(context, message);
    } else {
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.export_no_items,
      );
    }
  }

  void _showImportResult(BuildContext context, BulkImportResult result) {
    if (result.success) {
      final parts = <String>[];
      if (result.imported.isNotEmpty) {
        parts.add(
          context.t.settings.backup_and_restore.imported_count.replaceAll(
            '{count}',
            result.imported.length.toString(),
          ),
        );
      }
      if (result.skipped.isNotEmpty) {
        parts.add(
          context.t.settings.backup_and_restore.skipped_count.replaceAll(
            '{count}',
            result.skipped.length.toString(),
          ),
        );
      }
      if (result.failed.isNotEmpty) {
        parts.add(
          context.t.settings.backup_and_restore.failed_count.replaceAll(
            '{count}',
            result.failed.length.toString(),
          ),
        );
      }

      showSuccessToast(
        context,
        context.t.settings.backup_and_restore.import_results.replaceAll(
          '{results}',
          parts.join(', '),
        ),
      );
    } else {
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.import_no_items,
      );
    }
  }
}

bool _isPathAccessException(Exception e) {
  return e is PathAccessException ||
      e.toString().contains('PathAccessException');
}
