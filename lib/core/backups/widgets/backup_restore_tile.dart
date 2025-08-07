// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/picker.dart';
import '../../../foundation/toast.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../preparation/preparation_pipeline.dart';
import '../types/backup_data_source.dart';
import '../utils/backup_file_picker.dart';

class DefaultBackupTile extends ConsumerWidget {
  const DefaultBackupTile({
    required this.source,
    required this.title,
    required this.icon,
    this.subtitle,
    this.subtitleStyle,
    this.fileExtensions = const ['json'],
    this.forceAnyFileType = false,
    this.customActions = const {},
    this.onCustomAction,
    this.extra,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionTap,
    super.key,
  });

  final BackupDataSource source;
  final String title;
  final IconData icon;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final List<String> fileExtensions;
  final bool forceAnyFileType;
  final Map<String, Widget> customActions;
  final void Function(BuildContext, WidgetRef, String)? onCustomAction;
  final List<Widget>? extra;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = source.capabilities;
    final actions = <String, Widget>{};

    if (capabilities.file != null) {
      actions['export'] = Text(context.t.settings.backup_and_restore.export);
      actions['import'] = Text(context.t.settings.backup_and_restore.import);
    }

    if (capabilities.clipboard != null) {
      actions['exportClipboard'] = Text(
        context.t.settings.backup_and_restore.export_to_clipboard,
      );
      actions['importClipboard'] = Text(
        context.t.settings.backup_and_restore.import_from_clipboard,
      );
    }

    actions.addAll(customActions);

    return GestureDetector(
      onTap: isSelectionMode ? onSelectionTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                fill: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style:
                          subtitleStyle ??
                          TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.hintColor,
                          ),
                    ),
                  if (extra != null) ...extra!,
                ],
              ),
            ),
            if (!isSelectionMode)
              BooruPopupMenuButton(
                onSelected: (value) => _handleAction(context, ref, value),
                itemBuilder: actions,
              ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String actionType) {
    switch (actionType) {
      case 'export':
        _handleFileExport(context);
      case 'import':
        _handleFileImport(context, ref);
      case 'exportClipboard':
        _handleClipboardExport(context);
      case 'importClipboard':
        _handleClipboardImport(context);
      default:
        onCustomAction?.call(context, ref, actionType);
    }
  }

  void _handleFileExport(BuildContext context) {
    final fileCapability = source.capabilities.file;
    if (fileCapability == null) return;

    pickDirectoryPathToastOnError(
      context: context,
      onPick: (path) async {
        try {
          await fileCapability.export(path);
          if (context.mounted) {
            showSuccessToast(
              context,
              context.t.settings.backup_and_restore.export_success.replaceAll(
                '{source}',
                source.displayName,
              ),
            );
          }
        } catch (error) {
          if (context.mounted) {
            showErrorToast(
              context,
              context.t.settings.backup_and_restore.export_failed
                  .replaceAll('{source}', source.displayName.toLowerCase())
                  .replaceAll('{error}', error.toString()),
            );
          }
        }
      },
    );
  }

  void _handleFileImport(BuildContext context, WidgetRef ref) {
    final fileCapability = source.capabilities.file;
    if (fileCapability == null) return;

    BackupFilePicker.pickFile(
      context: context,
      androidDeviceInfo: ref.read(deviceInfoProvider).androidDeviceInfo,
      allowedExtensions: fileExtensions,
      forceAnyFileType: forceAnyFileType,
      onPick: (path) async {
        try {
          final preparation = await fileCapability.prepareImport(path, context);
          await preparation.executeImport();
          if (context.mounted) {
            showSuccessToast(
              context,
              context.t.settings.backup_and_restore.import_success.replaceAll(
                '{source}',
                source.displayName,
              ),
            );
          }
        } on ImportCancelledException {
          // User cancelled, no error message needed
        } catch (error) {
          if (context.mounted) {
            showErrorToast(
              context,
              context.t.settings.backup_and_restore.import_failed
                  .replaceAll('{source}', source.displayName.toLowerCase())
                  .replaceAll('{error}', error.toString()),
            );
          }
        }
      },
    );
  }

  Future<void> _handleClipboardExport(BuildContext context) async {
    final clipboardCapability = source.capabilities.clipboard;
    if (clipboardCapability == null) return;

    try {
      await clipboardCapability.export();
      if (context.mounted) {
        showSuccessToast(
          context,
          context.t.settings.backup_and_restore.clipboard_export_success
              .replaceAll('{source}', source.displayName),
        );
      }
    } catch (error) {
      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.clipboard_export_failed
              .replaceAll('{source}', source.displayName.toLowerCase())
              .replaceAll('{error}', error.toString()),
        );
      }
    }
  }

  Future<void> _handleClipboardImport(BuildContext context) async {
    final clipboardCapability = source.capabilities.clipboard;
    if (clipboardCapability == null) return;

    try {
      final preparation = await clipboardCapability.prepareImport(context);
      await preparation.executeImport();
      if (context.mounted) {
        showSuccessToast(
          context,
          context.t.settings.backup_and_restore.clipboard_import_success
              .replaceAll('{source}', source.displayName),
        );
      }
    } on ImportCancelledException {
      // User cancelled, no error message needed
    } catch (error) {
      if (context.mounted) {
        showErrorToast(
          context,
          context.t.settings.backup_and_restore.clipboard_import_failed
              .replaceAll('{source}', source.displayName.toLowerCase())
              .replaceAll('{error}', error.toString()),
        );
      }
    }
  }
}
