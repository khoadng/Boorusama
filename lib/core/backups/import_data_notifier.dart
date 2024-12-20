// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/config.dart';
import '../configs/manage.dart';
import '../servers/servers.dart';
import '../tags/favorites/providers.dart';

final importDataProvider = NotifierProvider.autoDispose
    .family<ImportDataNotifier, ImportDataState, String>(
  ImportDataNotifier.new,
);

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
