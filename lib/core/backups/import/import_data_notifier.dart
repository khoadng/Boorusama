// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../blacklists/providers.dart';
import '../../bookmarks/bookmark.dart';
import '../../bookmarks/providers.dart';
import '../../bulk_downloads/providers.dart';
import '../../configs/config.dart';
import '../../configs/manage.dart';
import '../../search/histories/providers.dart';
import '../../settings/providers.dart';
import '../../settings/settings.dart';
import '../../tags/favorites/providers.dart';
import '../db_transfer.dart';
import '../servers/server_providers.dart';

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
      reloadPayload:
          reloadPayload != null ? reloadPayload() : this.reloadPayload,
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
        for (final t in selectedTasks)
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
      await Future.delayed(const Duration(milliseconds: 250));

      try {
        switch (task.id) {
          case 'favorite_tags':
            final res = await dio.get('/favorite_tags');

            final tagString = res.data;

            final favTagsNotifier = ref.read(favoriteTagsProvider.notifier);

            await favTagsNotifier.importWithLabelsFromRawString(
              text: tagString,
            );

          case 'booru_configs':
            final res = await dio.get('/configs');

            final jsonString = res.data;

            await ref.read(booruConfigProvider.notifier).importFromRawString(
                  jsonString: jsonString,
                  onWillImport: (data) async => true,
                  onSuccess: (message, configs) {
                    final config = configs.first;

                    state = state.copyWith(
                      reloadPayload: () => ReloadPayload(
                        configs: configs,
                        selectedConfig: config,
                      ),
                    );
                  },
                  onFailure: (message) => throw Exception(message),
                );

          case 'settings':
            final res = await dio.get('/settings');

            final jsonString = res.data;

            final json = jsonDecode(jsonString) as Map<String, dynamic>;

            final settings = Settings.fromJson(json);

            await ref.read(settingsNotifierProvider.notifier).updateSettings(
                  settings,
                );

          case 'blacklisted_tags':
            final res = await dio.get('/blacklisted_tags');

            final jsonData = res.data;

            final map = jsonDecode(jsonData) as Map<String, dynamic>;
            final tagString = map['tags'] as String;

            await ref.read(globalBlacklistedTagsProvider.notifier).addTagString(
              tagString,
              onError: () {
                throw Exception('Failed to import blacklisted tags');
              },
            );

          case 'bookmarks':
            final currentBookmarks = ref.read(bookmarkProvider).bookmarks;
            final bookmarkRepository = ref.read(bookmarkRepoProvider);
            final bookmarkNotifier = ref.read(bookmarkProvider.notifier);

            final res = await dio.get('/bookmarks');

            final jsonString = res.data;

            final json = jsonDecode(jsonString) as List<dynamic>;

            final bookmarks = json
                .map((bookmark) => Bookmark.fromJson(bookmark))
                .toList()
                // remove duplicates
                .where(
                  (bookmark) =>
                      !currentBookmarks.containsKey(bookmark.originalUrl),
                )
                .toList();

            await bookmarkRepository.addBookmarkWithBookmarks(bookmarks);

            await bookmarkNotifier.getAllBookmarks();

          case 'search_histories':
            final dbPath = await getSearchHistoryDbPath();
            await downloadAndReplaceDb(
              dio: dio,
              url: '/search_histories',
              filePath: dbPath,
            );

            ref.invalidate(searchHistoryRepoProvider);

          case 'downloads':
            final dbPath = await getDownloadsDbPath();
            await downloadAndReplaceDb(
              dio: dio,
              url: '/downloads',
              filePath: dbPath,
            );

            ref.invalidate(internalDownloadRepositoryProvider);
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
