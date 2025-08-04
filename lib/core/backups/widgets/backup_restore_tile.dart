// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = source.capabilities;
    final actions = <String, Widget>{};

    if (capabilities.file != null) {
      actions['export'] = const Text('Export');
      actions['import'] = const Text('Import');
    }

    if (capabilities.clipboard != null) {
      actions['exportClipboard'] = const Text('Export to clipboard');
      actions['importClipboard'] = const Text('Import from clipboard');
    }

    actions.addAll(customActions);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
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
          BooruPopupMenuButton(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: actions,
          ),
        ],
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
              '${source.displayName} exported successfully',
            );
          }
        } catch (error) {
          if (context.mounted) {
            showErrorToast(
              context,
              'Failed to export ${source.displayName.toLowerCase()}: $error',
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
      ref: ref,
      allowedExtensions: fileExtensions,
      forceAnyFileType: forceAnyFileType,
      onPick: (path) async {
        try {
          final preparation = await fileCapability.prepareImport(path, context);
          await preparation.executeImport();
          if (context.mounted) {
            showSuccessToast(
              context,
              '${source.displayName} imported successfully',
            );
          }
        } on ImportCancelledException {
          // User cancelled, no error message needed
        } catch (error) {
          if (context.mounted) {
            showErrorToast(
              context,
              'Failed to import ${source.displayName.toLowerCase()}: $error',
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
          '${source.displayName} copied to clipboard',
        );
      }
    } catch (error) {
      if (context.mounted) {
        showErrorToast(
          context,
          'Failed to copy ${source.displayName.toLowerCase()}: $error',
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
          '${source.displayName} imported from clipboard',
        );
      }
    } on ImportCancelledException {
      // User cancelled, no error message needed
    } catch (error) {
      if (context.mounted) {
        showErrorToast(
          context,
          'Failed to paste ${source.displayName.toLowerCase()}: $error',
        );
      }
    }
  }
}
