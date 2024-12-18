// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/config.dart';
import '../configs/manage.dart';
import '../servers/discovery_client.dart';
import '../servers/servers.dart';
import '../settings/src/widgets/settings_page_scaffold.dart';
import '../tags/favorites/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/booru_dialog.dart';
import '../widgets/reboot.dart';

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
    return SettingsPageScaffold(
      title: const Text(''),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        Text(
          'Nearby devices',
          style: Theme.of(context).textTheme.titleLarge,
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
                    onPressed: () {
                      showTransferOptionsDialog(
                        context,
                        url: url.toString(),
                      );
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
    );
  }
}

enum SelectStatus {
  unslected,
  selected,
}

sealed class ImportStatus {
  const ImportStatus();
}

final class ImportNotStarted extends ImportStatus {
  const ImportNotStarted();
}

final class Importing extends ImportStatus {
  const Importing();
}

final class ImportQueued extends ImportStatus {
  const ImportQueued();
}

final class ImportDone extends ImportStatus {
  const ImportDone();
}

final class ImportError extends ImportStatus {
  const ImportError(this.message);

  final String message;
}

enum ImportStep {
  selection,
  importing,
  done,
}

typedef ReloadPayload = ({
  List<BooruConfig> configs,
  BooruConfig selectedConfig,
});

class ImportTask extends Equatable {
  const ImportTask({
    required this.id,
    required this.name,
    required this.status,
    required this.importStatus,
  });

  final String id;
  final String name;
  final SelectStatus status;
  final ImportStatus importStatus;

  ImportTask copyWith({
    String? id,
    String? name,
    SelectStatus? status,
    ImportStatus? importStatus,
  }) {
    return ImportTask(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      importStatus: importStatus ?? this.importStatus,
    );
  }

  @override
  List<Object?> get props => [id, name, status, importStatus];
}

class ImportDataState extends Equatable {
  const ImportDataState({
    required this.tasks,
    required this.step,
    required this.reloadPayload,
  });

  final List<ImportTask> tasks;
  final ImportStep step;
  final ReloadPayload? reloadPayload;

  bool get atLeastOneSelected =>
      tasks.any((element) => element.status == SelectStatus.selected);

  ImportDataState copyWith({
    List<ImportTask>? tasks,
    ImportStep? step,
    ReloadPayload? Function()? reloadPayload,
  }) {
    return ImportDataState(
      tasks: tasks ?? this.tasks,
      step: step ?? this.step,
      reloadPayload:
          reloadPayload != null ? reloadPayload() : this.reloadPayload,
    );
  }

  @override
  List<Object?> get props => [tasks, step, reloadPayload];
}

class ImportDataNotifier
    extends AutoDisposeFamilyNotifier<ImportDataState, String> {
  @override
  ImportDataState build(String arg) {
    return ImportDataState(
      step: ImportStep.selection,
      reloadPayload: null,
      tasks: ref.watch(exportCategoriesProvider).map((category) {
        return ImportTask(
          id: category.name,
          name: category.displayName,
          status: SelectStatus.selected,
          importStatus: const ImportNotStarted(),
        );
      }).toList(),
    );
  }

  Future<void> startImport() async {
    state = state.copyWith(
      step: ImportStep.importing,
    );

    final selectedTasks = state.tasks.where((element) {
      return element.status == SelectStatus.selected;
    });

    if (selectedTasks.isEmpty) {
      state = state.copyWith(step: ImportStep.done);
      return;
    }

    final tasks = QueueList.from(
      selectedTasks,
    );

    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.status == SelectStatus.selected)
            t.copyWith(importStatus: const ImportQueued())
          else
            t,
      ],
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: arg,
      ),
    );

    while (tasks.isNotEmpty) {
      final task = tasks.removeFirst();

      state = state.copyWith(
        tasks: [
          for (final t in state.tasks)
            if (t.id == task.id)
              task.copyWith(importStatus: const Importing())
            else
              t,
        ],
      );

      // Artificial delay to make sure user sees the loading indicator
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        switch (task.id) {
          case 'favorite_tags':
            final res = await dio.get('/favorite_tags');

            final tagString = res.data;

            final favTagsNotifier = ref.read(favoriteTagsProvider.notifier);

            await favTagsNotifier.importWithLabelsFromRawString(
              text: tagString,
            );

            break;
          case 'booru_configs':
            final res = await dio.get('/configs');

            final jsonString = res.data;

            await ref.read(booruConfigProvider.notifier).importFromRawString(
                  jsonString: jsonString,
                  onWillImport: (data) async => true,
                  onSuccess: (message, configs) {
                    final config = configs.first;

                    state = state.copyWith(
                      reloadPayload: () => (
                        configs: configs,
                        selectedConfig: config,
                      ),
                    );
                  },
                  onFailure: (message) => throw Exception(message),
                );

            break;
        }

        state = state.copyWith(
          tasks: [
            for (final t in state.tasks)
              if (t.id == task.id)
                task.copyWith(importStatus: const ImportDone())
              else
                t,
          ],
        );
      } catch (e) {
        state = state.copyWith(
          tasks: [
            for (final t in state.tasks)
              if (t.id == task.id)
                task.copyWith(importStatus: ImportError(e.toString()))
              else
                t,
          ],
        );
      }
    }
  }

  void toggleTask(String id) {
    final task = state.tasks.firstWhereOrNull((element) => element.id == id);

    if (task == null) return;

    final newTask = task.copyWith(
      status: task.status == SelectStatus.selected
          ? SelectStatus.unslected
          : SelectStatus.selected,
    );

    state = state.copyWith(
      tasks: [
        for (final t in state.tasks)
          if (t.id == id) newTask else t,
      ],
    );
  }
}

final importDataProvider = NotifierProvider.autoDispose
    .family<ImportDataNotifier, ImportDataState, String>(
  ImportDataNotifier.new,
);

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
                          showDuration: const Duration(seconds: 3),
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
