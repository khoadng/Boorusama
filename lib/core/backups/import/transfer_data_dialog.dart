// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../settings/providers.dart';
import '../../settings/settings.dart';
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
    final colorScheme = theme.colorScheme;
    final reloadPayload =
        ref.watch(importDataProvider(url).select((s) => s.reloadPayload));
    final forceRestart =
        ref.watch(importDataProvider(url).select((s) => s.forceReload));

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            color: colorScheme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  final ImportError error => Row(
                      children: [
                        Icon(
                          Icons.close,
                          color: colorScheme.error,
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
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ImportDone _ => Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: colorScheme.primary,
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
          _buildCancelButton(context, isDone, reloadPayload, settings)
        else
          forceRestart
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'PLEASE CLOSE AND REOPEN THE APP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is required to apply all changes and prevent data corruption.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : reloadPayload != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
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
                              'Restart App',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCancelButton(
                          context,
                          isDone,
                          reloadPayload,
                          settings,
                        ),
                      ],
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

  Widget _buildCancelButton(
    BuildContext context,
    bool isDone,
    ReloadPayload? reloadPayload,
    Settings settings,
  ) {
    return !isDone
        ? FilledButton(
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
        : ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);

              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('App Restart Required'),
                  content: const Text(
                    'To apply all changes, the app needs to restart.'
                    '\n\nContinue without restarting? Some features may not work properly.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Continue Anyway'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Restart Now'),
                    ),
                  ],
                ),
              );

              if (result == null) return;

              if (result) {
                navigator.pop();
              } else {
                if (context.mounted && reloadPayload != null) {
                  Reboot.start(
                    context,
                    RebootData(
                      config: reloadPayload.selectedConfig,
                      configs: reloadPayload.configs,
                      settings: reloadPayload.settings ?? settings,
                    ),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
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
    final serverCheckNotifier = ref.watch(serverCheckProvider.notifier);
    final serverCheckStatus = ref.watch(serverCheckProvider);

    ref.listen(serverCheckProvider, (prev, next) {
      if (prev == ServerCheckStatus.checking &&
          next == ServerCheckStatus.available) {
        notifier.startImport();
      }
    });

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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => notifier.selectAllTasks(),
              child: const Text('Select All'),
            ),
            TextButton(
              onPressed: () => notifier.deselectAllTasks(),
              child: const Text('Deselect All'),
            ),
          ],
        ),
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
              ? switch (serverCheckStatus) {
                  ServerCheckStatus.initial => () {
                      serverCheckNotifier.check(url);
                    },
                  ServerCheckStatus.available => () {
                      notifier.startImport();
                    },
                  _ => null,
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              switch (serverCheckStatus) {
                ServerCheckStatus.initial => 'Import',
                ServerCheckStatus.available => 'Import',
                ServerCheckStatus.checking => 'Verifying...',
                ServerCheckStatus.unavailable => 'Unavailable',
              },
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
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
