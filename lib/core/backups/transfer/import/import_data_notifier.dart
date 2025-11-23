// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../configs/manage/providers.dart';
import '../../../settings/providers.dart';
import '../../../settings/types.dart';
import '../../sources/providers.dart';
import '../../types/types.dart';

final exportCategoriesProvider = Provider<List<ExportCategory>>((ref) {
  // Ensure all backup sources are registered
  ref.watch(allBackupSourcesProvider);

  final registry = ref.watch(backupRegistryProvider);

  // Get categories from the registry system
  final registryCategories = registry
      .getAllSources()
      .map(
        (source) => ExportCategory(
          name: source.id,
          displayName: source.displayName,
          route: source.id,
          handler: source.capabilities.server.export,
        ),
      )
      .toList();

  return registryCategories;
});

final importDataProvider = NotifierProvider.autoDispose
    .family<ImportDataNotifier, ImportDataState, String>(
      ImportDataNotifier.new,
    );

final serverCheckProvider =
    NotifierProvider.autoDispose<ServerCheckNotifier, ServerCheckStatus>(
      ServerCheckNotifier.new,
    );

enum ServerCheckStatus {
  initial,
  checking,
  available,
  unavailable,
}

class ServerCheckNotifier extends AutoDisposeNotifier<ServerCheckStatus> {
  @override
  ServerCheckStatus build() {
    return ServerCheckStatus.initial;
  }

  Future<void> check(String address) async {
    state = ServerCheckStatus.checking;

    final startTime = DateTime.now();

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: address,
        ),
      );

      final res = await dio.get('/health').timeout(const Duration(seconds: 10));
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;

      // Artificial delay to make sure things don't fly by too fast
      if (elapsed < 500) {
        await Future.delayed(Duration(milliseconds: 500 - elapsed));
      }

      final available = res.statusCode == 204;
      state = available
          ? ServerCheckStatus.available
          : ServerCheckStatus.unavailable;
    } catch (_) {
      state = ServerCheckStatus.unavailable;
    }
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

class ReloadPayload extends Equatable {
  const ReloadPayload({
    required this.configs,
    required this.selectedConfig,
    this.settings,
  });

  final List<BooruConfig> configs;
  final BooruConfig selectedConfig;
  final Settings? settings;

  ReloadPayload copyWith({
    List<BooruConfig>? configs,
    BooruConfig? selectedConfig,
    Settings? Function()? settings,
  }) {
    return ReloadPayload(
      configs: configs ?? this.configs,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      settings: settings != null ? settings() : this.settings,
    );
  }

  @override
  List<Object?> get props => [configs, selectedConfig, settings];
}

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
    required this.forceReload,
  });

  final List<ImportTask> tasks;
  final ImportStep step;
  final ReloadPayload? reloadPayload;
  final bool forceReload;

  bool get atLeastOneSelected =>
      tasks.any((element) => element.status == SelectStatus.selected);

  ImportDataState copyWith({
    List<ImportTask>? tasks,
    ImportStep? step,
    ReloadPayload? Function()? reloadPayload,
    bool? forceReload,
  }) {
    return ImportDataState(
      tasks: tasks ?? this.tasks,
      step: step ?? this.step,
      reloadPayload: reloadPayload != null
          ? reloadPayload()
          : this.reloadPayload,
      forceReload: forceReload ?? this.forceReload,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    step,
    reloadPayload,
    forceReload,
  ];
}

class ImportDataNotifier
    extends AutoDisposeFamilyNotifier<ImportDataState, String> {
  @override
  ImportDataState build(String arg) {
    return ImportDataState(
      step: ImportStep.selection,
      reloadPayload: null,
      forceReload: false,
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
        for (final tsk in selectedTasks)
          if (tsk.status == SelectStatus.selected)
            tsk.copyWith(importStatus: const ImportQueued())
          else
            tsk,
      ],
    );

    while (tasks.isNotEmpty) {
      final task = tasks.removeFirst();

      state = state.copyWith(
        tasks: [
          for (final tsk in state.tasks)
            if (tsk.id == task.id)
              task.copyWith(importStatus: const Importing())
            else
              tsk,
        ],
      );

      // Artificial delay to make sure user sees the loading indicator
      await Future.delayed(const Duration(milliseconds: 250));

      try {
        await _handleTask(task, arg);

        state = state.copyWith(
          tasks: [
            for (final tsk in state.tasks)
              if (tsk.id == task.id)
                task.copyWith(importStatus: const ImportDone())
              else
                tsk,
          ],
        );
      } catch (e) {
        state = state.copyWith(
          tasks: [
            for (final tsk in state.tasks)
              if (tsk.id == task.id)
                task.copyWith(importStatus: ImportError(e.toString()))
              else
                tsk,
          ],
        );
      }
    }

    final importedTaskIds = selectedTasks.map((t) => t.id).toSet();
    if (importedTaskIds.contains('profiles')) {
      final configRepo = ref.read(booruConfigRepoProvider);
      final configs = await configRepo.getAll();

      if (configs.isNotEmpty) {
        state = state.copyWith(
          reloadPayload: () => ReloadPayload(
            configs: configs,
            selectedConfig: configs.first,
            settings: ref.read(settingsProvider),
          ),
        );
      }
    }
  }

  Future<void> _handleTask(ImportTask task, String serverUrl) async {
    final registry = ref.read(backupRegistryProvider);
    final source = registry.getSource(task.id);

    if (source == null) {
      throw Exception('Unknown backup source: ${task.id}');
    }

    final preparation = await source.capabilities.server.prepareImport(
      serverUrl,
      null, // No UI context for server transfers
    );

    // For server transfers, we accept all version checks automatically
    // since the transfer was already initiated by the user
    await preparation.executeImport();
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
        for (final tsk in state.tasks)
          if (tsk.id == id) newTask else tsk,
      ],
    );
  }

  void selectAllTasks() {
    state = state.copyWith(
      tasks: state.tasks
          .map(
            (task) => task.copyWith(
              status: SelectStatus.selected,
            ),
          )
          .toList(),
    );
  }

  void deselectAllTasks() {
    state = state.copyWith(
      tasks: state.tasks
          .map(
            (task) => task.copyWith(
              status: SelectStatus.unslected,
            ),
          )
          .toList(),
    );
  }
}
