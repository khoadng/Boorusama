// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import '../../foundation/toast.dart';
import '../../foundation/version.dart';
import '../../info/package_info.dart';
import '../servers/discovery_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/booru_dialog.dart';
import '../../widgets/reboot.dart';
import 'import_data_notifier.dart';
import 'version_mismatch_alert_dialog.dart';

class ImportDataPage extends ConsumerStatefulWidget {
  const ImportDataPage({super.key});

  @override
  ConsumerState<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends ConsumerState<ImportDataPage> {
  List<BonsoirService> discoveredServices = [];
  late final _client = DiscoveryClient(
    onServiceResolved: _handleServiceResolved,
    onServiceLost: _handleServiceLost,
  );

  @override
  void initState() {
    super.initState();

    discoverServers();
  }

  void _handleServiceResolved(BonsoirService service) {
    if (!mounted) return;
    setState(() {
      if (!discoveredServices.any((element) => element.name == service.name)) {
        discoveredServices.add(service);
      }
    });
  }

  void _handleServiceLost(BonsoirService service) {
    if (!mounted) return;
    setState(() {
      discoveredServices.removeWhere((element) => element.name == service.name);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _client.stopDiscovery();
  }

  Future<void> discoverServers() async {
    _client.startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive data'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby devices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (discoveredServices.isNotEmpty)
              Column(
                children: discoveredServices.map((service) {
                  final address = service.attributes['ip'];
                  final port = service.attributes['port'];
                  final appVersion = service.attributes['version'];
                  final url = Uri(
                    scheme: 'http',
                    host: address,
                    port: int.tryParse(port ?? ''),
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Version $appVersion',
                      ),
                      trailing: TextButton(
                        child: const Text('Import'),
                        onPressed: () async {
                          if (appVersion == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine this device's version, aborting.",
                            );
                            return;
                          }

                          if (currentVersion == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine the current version, aborting.",
                            );
                            return;
                          }

                          final parsedVersion = Version.parse(appVersion);
                          final shouldShowDialog = currentVersion
                                  .significantlyLowerThan(parsedVersion) ||
                              currentVersion
                                  .significantlyHigherThan(parsedVersion);

                          if (shouldShowDialog) {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => VersionMismatchAlertDialog(
                                importVersion: Version.parse(appVersion),
                                currentVersion: currentVersion,
                              ),
                            );

                            if (result == null || !result) return;
                          }

                          if (context.mounted) {
                            showTransferOptionsDialog(
                              context,
                              url: url.toString(),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Center(
                child: Text(
                  'No devices found',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.hintColor,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TransferOptionsDialog extends ConsumerWidget {
  const TransferOptionsDialog({
    super.key,
    required this.url,
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
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      reloadPayload.selectedConfig,
                      reloadPayload.configs,
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
    super.key,
    required this.url,
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
  showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TransferOptionsDialog(
      url: url,
    ),
  );
}
