// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../types/backup_data_source.dart';
import 'types.dart';

class ZipPreviewDialog extends ConsumerStatefulWidget {
  const ZipPreviewDialog({
    required this.previewResult,
    super.key,
  });

  final ZipPreviewResult previewResult;

  @override
  ConsumerState<ZipPreviewDialog> createState() => _ZipPreviewDialogState();
}

class _ZipPreviewDialogState extends ConsumerState<ZipPreviewDialog> {
  late Set<String> selectedSourceIds;

  @override
  void initState() {
    super.initState();
    // Initially select all available sources
    selectedSourceIds = widget.previewResult.availableSources
        .map((source) => source.id)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final availableSources = widget.previewResult.availableSources;
    final theme = Theme.of(context);

    return BooruDialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              'Preview Backup'.hc,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfo(theme),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select data to import:'.hc,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (availableSources.isNotEmpty) ...[
              _buildSources(availableSources),
            ],

            const SizedBox(height: 12),

            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSources(List<BackupDataSource> availableSources) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: availableSources.map((source) {
            final isSelected = selectedSourceIds.contains(source.id);
            return CheckboxListTile(
              title: Text(source.displayName),
              value: isSelected,
              onChanged: (value) => _toggleSource(source.id, value ?? false),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.t.generic.action.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: selectedSourceIds.isEmpty
                ? null
                : () => Navigator.of(
                    context,
                  ).pop(selectedSourceIds.toList()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.t.settings.backup_and_restore.import,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(ThemeData theme) {
    final manifest = widget.previewResult.manifest;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Created:',
            value: DateFormat(
              'MMM d, yyyy h:mm a',
            ).format(manifest.exportDate),
          ),
          if (manifest.appVersion != null)
            _InfoRow(
              label: 'App Version:',
              value: manifest.appVersion!,
            ),
          _InfoRow(
            label: 'Total:',
            value: '${manifest.sources.length}',
          ),
        ],
      ),
    );
  }

  void _toggleSource(String sourceId, bool selected) {
    setState(() {
      if (selected) {
        selectedSourceIds.add(sourceId);
      } else {
        selectedSourceIds.remove(sourceId);
      }
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>?> showZipPreviewDialog(
  BuildContext context,
  ZipPreviewResult previewResult,
) {
  return showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ZipPreviewDialog(previewResult: previewResult),
  );
}
