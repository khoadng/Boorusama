// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'l10n.dart';

final downloadFilterProvider =
    StateProvider.family<DownloadFilter, String?>((ref, initialFilter) {
  return _convertFilter(initialFilter);
});

final downloadGroupProvider = Provider<String>(
  (ref) => FileDownloader.defaultGroup,
  name: 'downloadGroupProvider',
);

DownloadFilter _convertFilter(String? filter) => switch (filter) {
      'error' => DownloadFilter.failed,
      'running' => DownloadFilter.inProgress,
      'complete' => DownloadFilter.completed,
      _ => DownloadFilter.all,
    };

final downloadFilteredProvider =
    Provider.family<List<TaskUpdate>, String?>((ref, initialFilter) {
  final filter = ref.watch(downloadFilterProvider(initialFilter));
  final group = ref.watch(downloadGroupProvider);
  final state = ref.watch(downloadTasksProvider);

  return switch (filter) {
    DownloadFilter.all => state.all(group),
    DownloadFilter.pending => state.pending(group),
    DownloadFilter.paused => state.paused(group),
    DownloadFilter.inProgress => state.inProgress(group),
    DownloadFilter.completed => state.completed(group),
    DownloadFilter.failed => state.failed(group),
    DownloadFilter.canceled => state.canceled(group),
  };
}, dependencies: [
  downloadGroupProvider,
]);

class DownloadManagerGatewayPage extends ConsumerWidget {
  const DownloadManagerGatewayPage({
    super.key,
    this.filter,
    this.group,
  });

  final String? filter;
  final String? group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        downloadGroupProvider
            .overrideWithValue(group ?? FileDownloader.defaultGroup),
      ],
      child: DownloadManagerPage(
        filter: filter,
      ),
    );
  }
}

class DisabledDownloadManagerPage extends StatelessWidget {
  const DisabledDownloadManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download manager is disabled',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'You are using the legacy downloader. Please enable the new downloader in the settings.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  openDownloadSettingsPage(context);
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _filterOptions = [
  DownloadFilter.all,
  DownloadFilter.inProgress,
  DownloadFilter.pending,
  DownloadFilter.paused,
  DownloadFilter.failed,
  DownloadFilter.canceled,
  DownloadFilter.completed,
];

class DownloadManagerPage extends ConsumerStatefulWidget {
  const DownloadManagerPage({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  ConsumerState<DownloadManagerPage> createState() =>
      _DownloadManagerPageState();
}

class _DownloadManagerPageState extends ConsumerState<DownloadManagerPage> {
  final scrollController = AutoScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.filter != null) {
      // scroll to the selected filter
      final filterType = _convertFilter(widget.filter);
      final index = _filterOptions.indexOf(filterType);

      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          scrollController.scrollToIndex(
            index,
            preferPosition: AutoScrollPosition.end,
            duration: const Duration(milliseconds: 100),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadFilteredProvider(widget.filter));
    final group = ref.watch(downloadGroupProvider);
    final isDefaultGroup = group == FileDownloader.defaultGroup;

    return Scaffold(
      appBar: AppBar(
        title: const Text(DownloadTranslations.downloadManagerTitle).tr(),
        actions: isDefaultGroup
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    openDownloadSettingsPage(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // clear default group only
                    ref.read(downloadTasksProvider.notifier).clear(
                      FileDownloader.defaultGroup,
                      onFailed: () {
                        showSimpleSnackBar(
                          context: context,
                          content:
                              Text(DownloadTranslations.downloadNothingToClear)
                                  .tr(),
                          duration: const Duration(seconds: 1),
                        );
                      },
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) {
                final selectedFilter =
                    ref.watch(downloadFilterProvider(widget.filter));

                return ChoiceOptionSelectorList(
                  scrollController: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  searchable: false,
                  options: _filterOptions,
                  hasNullOption: false,
                  optionLabelBuilder: (value) => value!.localize().tr(),
                  onSelected: (value) {
                    if (value == null) return;

                    ref
                        .read(downloadFilterProvider(widget.filter).notifier)
                        .state = value;
                  },
                  selectedOption: selectedFilter,
                );
              },
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: tasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return SimpleDownloadTile(
                            task: task,
                            onResume: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().resume(dt);
                            },
                            onPause: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().pause(dt);
                            },
                            onResumeFailed: () {
                              final dt = castOrNull<DownloadTask>(task.task);

                              if (dt == null) return;

                              FileDownloader().resume(dt);
                            },
                            onRestart: () {
                              FileDownloader().enqueue(task.task);
                            },
                            onCancel: () {
                              FileDownloader()
                                  .cancelTaskWithId(task.task.taskId);
                            },
                          );
                        },
                      )
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              ref
                                  .watch(downloadFilterProvider(widget.filter))
                                  .emptyLocalize(),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
              ),
            ),
            RetryAllFailedButton(filter: widget.filter),
          ],
        ),
      ),
    );
  }
}

class RetryAllFailedButton extends ConsumerWidget {
  const RetryAllFailedButton({
    super.key,
    this.filter,
  });

  final String? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(downloadTasksProvider).failed(
          ref.watch(downloadGroupProvider),
        );

    return ref.watch(downloadFilterProvider(filter)) == DownloadFilter.failed &&
            failed.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () {
                for (final task in failed) {
                  final dt = castOrNull<DownloadTask>(task.task);

                  if (dt == null) continue;

                  FileDownloader().enqueue(dt);
                }
              },
              child: const Text(DownloadTranslations.retryAllFailed).tr(),
            ),
          )
        : const SizedBox.shrink();
  }
}

final _checkResumableProvider =
    FutureProvider.autoDispose.family<bool, Task>((ref, task) async {
  return FileDownloader().taskCanResume(task);
});

extension TaskCancelX on TaskUpdate {
  bool get isCanceled => switch (this) {
        final TaskStatusUpdate u => u.status == TaskStatus.canceled,
        TaskProgressUpdate _ => false,
      };

  bool get canCancel => switch (this) {
        final TaskStatusUpdate u => switch (u.status) {
            TaskStatus.failed => false,
            TaskStatus.paused => false,
            TaskStatus.running => true,
            TaskStatus.enqueued => true,
            TaskStatus.complete => false,
            TaskStatus.notFound => false,
            TaskStatus.canceled => false,
            TaskStatus.waitingToRetry => true,
          },
        TaskProgressUpdate _ => true,
      };
}

final _filePathProvider = FutureProvider.autoDispose
    .family<String, Task>((ref, task) => task.filePath());

class SimpleDownloadTile extends ConsumerWidget {
  const SimpleDownloadTile({
    super.key,
    required this.task,
    required this.onResume,
    required this.onPause,
    required this.onResumeFailed,
    required this.onRestart,
    required this.onCancel,
  });

  final TaskUpdate task;
  final void Function() onResume;
  final void Function() onPause;
  final void Function() onResumeFailed;
  final void Function() onRestart;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = DownloaderMetadata.fromJsonString(task.task.metaData);

    return DownloadTileBuilder(
      url: task.task.url,
      thumbnailUrl: metadata.thumbnailUrl,
      siteUrl: metadata.siteUrl,
      fileSize: task.fileSize,
      networkSpeed: switch (task) {
        TaskStatusUpdate _ => null,
        final TaskProgressUpdate p => p.hasNetworkSpeed ? p.networkSpeed : null,
      },
      timeRemaining: switch (task) {
        TaskStatusUpdate _ => null,
        final TaskProgressUpdate p =>
          p.hasTimeRemaining ? p.timeRemaining : null,
      },
      onCancel: task.canCancel ? onCancel : null,
      builder: (_) => RawDownloadTile(
        fileName: task.task.filename,
        strikeThrough: task.isCanceled,
        color: task.isCanceled ? context.colorScheme.hintColor : null,
        trailing: switch (task) {
          final TaskStatusUpdate s => switch (s.status) {
              TaskStatus.failed =>
                ref.watch(_checkResumableProvider(task.task)).when(
                      data: (value) => value
                          ? IconButton(
                              onPressed: () => onResumeFailed.call(),
                              icon: const Icon(
                                Symbols.refresh,
                                fill: 1,
                              ),
                            )
                          : IconButton(
                              onPressed: () => onRestart.call(),
                              icon: const Icon(
                                Symbols.refresh,
                                fill: 1,
                              ),
                            ),
                      loading: () => const Center(
                        child: SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
              TaskStatus.paused => IconButton(
                  onPressed: () => onResume.call(),
                  icon: const Icon(
                    Symbols.play_arrow,
                    fill: 1,
                  ),
                ),
              TaskStatus.running => IconButton(
                  onPressed: () => onPause(),
                  icon: const Icon(
                    Symbols.pause,
                    fill: 1,
                  ),
                ),
              TaskStatus.complete => const Icon(
                  Symbols.download_done,
                  color: Colors.green,
                ),
              TaskStatus.enqueued => const SizedBox.shrink(),
              TaskStatus.notFound => const SizedBox.shrink(),
              TaskStatus.canceled => const SizedBox.shrink(),
              TaskStatus.waitingToRetry =>
                const Center(child: CircularProgressIndicator()),
            },
          TaskProgressUpdate _ => IconButton(
              onPressed: () => onPause(),
              icon: const Icon(
                Symbols.pause,
                fill: 1,
              ),
            ),
        },
        subtitle: switch (task) {
          final TaskStatusUpdate s => _TaskSubtitle(task: s),
          final TaskProgressUpdate p => p.progress >= 0
              ? LinearPercentIndicator(
                  lineHeight: 2,
                  percent: p.progress,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  animation: true,
                  animateFromLastPercent: true,
                  trailing: Text(
                    '${(p.progress * 100).floor()}%',
                  ),
                )
              : const SizedBox.shrink(),
        },
        url: task.task.url,
      ),
    );
  }
}

class _TaskSubtitle extends ConsumerWidget {
  const _TaskSubtitle({
    required this.task,
  });

  final TaskStatusUpdate task;

  String _prettifyFilePathIfNeeded(String path) {
    if (isAndroid()) {
      if (path.startsWith('/storage/emulated/0/')) {
        return path.replaceAll('/storage/emulated/0/', '/');
      }
    }

    return path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = task;
    return ReadMoreText(
      s.exception?.description == null
          ? switch (s.status) {
              TaskStatus.complete =>
                ref.watch(_filePathProvider(task.task)).maybeWhen(
                      data: (data) => _prettifyFilePathIfNeeded(data),
                      orElse: () => '...',
                    ),
              _ => s.status.name.sentenceCase,
            }
          : 'Failed: ${s.exception!.description} ',
      trimLines: 1,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' more',
      trimExpandedText: ' less',
      lessStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: context.colorScheme.primary,
      ),
      moreStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: context.colorScheme.primary,
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.hintColor,
        fontSize: 12,
      ),
    );
  }
}
