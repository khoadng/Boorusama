// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/picker.dart';
import '../../../foundation/toast.dart';
import '../../settings/providers.dart';
import '../auto/auto_backup_service.dart';
import '../auto/auto_backup_settings.dart';
import '../sources/providers.dart';
import '../utils/backup_file_picker.dart';
import 'bulk_backup_service.dart';

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
  Future<void> exportAll(BuildContext context) async {
    final registry = ref.read(backupRegistryProvider);
    final allSourceIds = registry.getAllSources().map((s) => s.id).toList();
    return exportToZip(context, allSourceIds);
  }

  Future<void> exportToZip(BuildContext context, List<String> sourceIds) async {
    if (state.isActive) {
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.backup_in_progress,
      );
      return;
    }

    try {
      state = state.copyWith(
        status: BackupStatus.exporting,
        progress: 0,
        error: null,
      );

      final path = await _pickExportDirectory(context);
      if (path == null) {
        state = state.copyWith(status: BackupStatus.idle);
        return;
      }

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

      if (context.mounted) {
        _showExportResult(context, result);
      }
    } catch (e) {
      state = state.copyWith(
        status: BackupStatus.error,
        error: e.toString(),
      );

      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.export_operation_failed
              .replaceAll('{error}', e.toString()),
        );
      }
    }
  }

  Future<void> importFromZip(
    BuildContext context, {
    List<String>? onlySourceIds,
  }) async {
    if (state.isActive) {
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.backup_in_progress,
      );
      return;
    }

    try {
      state = state.copyWith(
        status: BackupStatus.importing,
        progress: 0,
        error: null,
      );

      await BackupFilePicker.pickFile(
        context: context,
        androidDeviceInfo: ref.read(deviceInfoProvider).androidDeviceInfo,
        allowedExtensions: ['zip'],
        onPick: (path) async {
          final service = ref.read(bulkBackupServiceProvider);
          final result = await service.importFromZip(
            path,
            context,
            onlySourceIds: onlySourceIds,
          );

          state = state.copyWith(
            status: BackupStatus.completed,
            importResult: result,
            progress: 1,
          );

          if (context.mounted) {
            _showImportResult(context, result);
          }
        },
      );

      // If we get here without importing, user cancelled
      if (state.status == BackupStatus.importing) {
        state = state.copyWith(status: BackupStatus.idle);
      }
    } catch (e) {
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
    if (state.isActive) return;

    if (!settings.shouldBackup) return;

    await _performAutoBackup(settings, isManual: false);
  }

  Future<void> performManualAutoBackup(AutoBackupSettings settings) async {
    if (state.isActive) return;

    await _performAutoBackup(settings, isManual: true);
  }

  Future<void> _performAutoBackup(
    AutoBackupSettings settings, {
    required bool isManual,
  }) async {
    final startTime = DateTime.now();

    try {
      state = state.copyWith(
        status: BackupStatus.exporting,
        progress: 0,
        error: null,
      );

      final autoBackupService = ref.read(autoBackupServiceProvider);
      final result = await autoBackupService.performBackup(
        settings,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );

      if (result.success) {
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
      }

      state = state.copyWith(
        status: BackupStatus.completed,
        exportResult: result,
        progress: 1,
      );
    } catch (e) {
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
