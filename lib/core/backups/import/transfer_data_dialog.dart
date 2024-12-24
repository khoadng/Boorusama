// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../settings/providers.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import 'import_data_notifier.dart';

class TransferDataDialog extends ConsumerWidget {
  const TransferDataDialog({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final step = ref.watch(importDataProvider(url).select((s) => s.step));

    return BooruDialog(
      color: theme.colorScheme.surfaceContainerLow,
      dismissible: false,
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: theme.listTileTheme.copyWith(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
          ),
        ),
        child: switch (step) {
          ImportStep.selection => SelectDataStep(url: url),
          _ => ImportingStep(
              url: url,
            ),
        },
      ),
    );
  }
}

class ImportingStep extends ConsumerWidget {
  const ImportingStep({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final tasks = ref.watch(importDataProvider(url).select((s) => s.tasks));
    final isDone = tasks.every((element) {
      return element.importStatus is ImportDone;
    });

    final theme = Theme.of(context);
    final reloadPayload =
        ref.watch(importDataProvider(url).select((s) => s.reloadPayload));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Importing...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [
              ...tasks.map((task) {
                return switch (task.importStatus) {
                  ImportNotStarted _ => Text(task.name),
                  Importing _ => Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(task.name),
                      ],
                    ),
                  ImportQueued _ => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 28),
                        Text(
                          task.name,
                          style: TextStyle(
                            color: theme.colorScheme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  final ImportError error => Row(
                      children: [
                        Icon(
                          Icons.close,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(task.name),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: error.message,
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: const Duration(seconds: 5),
                          child: Icon(
                            Icons.error,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ImportDone _ => Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(task.name),
                      ],
                    ),
                };
              }),
            ],
          ),
        ),
        if (!isDone)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          reloadPayload != null
              ? FilledButton(
                  onPressed: () {
                    Reboot.start(
                      context,
                      RebootData(
                        config: reloadPayload.selectedConfig,
                        configs: reloadPayload.configs,
                        settings: reloadPayload.settings ?? settings,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Reboot',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
      ],
    );
  }
}

class SelectDataStep extends ConsumerWidget {
  const SelectDataStep({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importDataProvider(url));
    final options = state.tasks;
    final notifier = ref.watch(importDataProvider(url).notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Choose data to import',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map(
          (e) => CheckboxListTile(
            title: Text(e.name),
            value: e.status == SelectStatus.selected,
            onChanged: (value) {
              if (value == null) return;

              notifier.toggleTask(e.id);
            },
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: state.atLeastOneSelected
              ? () {
                  notifier.startImport();
                }
              : null,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Import',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showTransferOptionsDialog(
  BuildContext context, {
  required String url,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TransferDataDialog(
      url: url,
    ),
  );
}
