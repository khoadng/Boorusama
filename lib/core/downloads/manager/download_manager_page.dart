// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../core/widgets/widgets.dart';
import '../../configs/config.dart';
import '../../configs/ref.dart';
import '../../foundation/platform.dart';
import '../../foundation/toast.dart';
import '../../foundation/url_launcher.dart';
import '../../http/http.dart';
import '../../http/providers.dart';
import '../../images/providers.dart';
import '../../settings/routes.dart';
import '../../theme.dart';
import '../downloader/background_downloader.dart';
import '../downloader/metadata.dart';
import '../internal_widgets/download_tile.dart';
import '../l10n.dart';
import 'download_filter.dart';
import 'download_task_update.dart';
import 'download_task_updates_notifier.dart';

final downloadFilterProvider =
    StateProvider.family<DownloadFilter, String?>((ref, initialFilter) {
  return convertFilter(initialFilter);
});

final downloadGroupProvider = Provider<String>(
  (ref) => FileDownloader.defaultGroup,
  name: 'downloadGroupProvider',
);

final downloadFilteredProvider = Provider.family<List<TaskUpdate>, String?>(
  (ref, initialFilter) {
    final filter = ref.watch(downloadFilterProvider(initialFilter));
    final group = ref.watch(downloadGroupProvider);
    final state = ref.watch(downloadTaskUpdatesProvider);

    return switch (filter) {
      DownloadFilter.pending => state.pending(group),
      DownloadFilter.paused => state.paused(group),
      DownloadFilter.inProgress => state.inProgress(group),
      DownloadFilter.completed => state.completed(group),
      DownloadFilter.failed => state.failed(group),
      DownloadFilter.canceled => state.canceled(group),
    };
  },
  dependencies: [
    downloadGroupProvider,
  ],
);

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

class DisabledDownloadManagerPage extends ConsumerWidget {
  const DisabledDownloadManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'You are using the legacy downloader. Please enable the new downloader in the settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.hintColor,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  openDownloadSettingsPage(ref);
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
  DownloadFilter.completed,
  DownloadFilter.inProgress,
  DownloadFilter.pending,
  DownloadFilter.paused,
  DownloadFilter.failed,
  DownloadFilter.canceled,
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
  final _multiSelectController = MultiSelectController();

  @override
  void initState() {
    super.initState();

    if (widget.filter != null) {
      // scroll to the selected filter
      final filterType = convertFilter(widget.filter);
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
    scrollController.dispose();
    _multiSelectController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadFilteredProvider(widget.filter));
    final config = ref.watchConfig;

    return MultiSelectWidget(
      controller: _multiSelectController,
      footer: ValueListenableBuilder(
        valueListenable: _multiSelectController.selectedItemsNotifier,
        builder: (_, selectedItems, __) => MultiSelectionActionBar(
          children: [
            MultiSelectButton(
              onPressed: selectedItems.isNotEmpty
                  ? () async {
                      final futures = selectedItems
                          .map((index) => tasks[index].task.filePath())
                          .toList();
                      final paths = await Future.wait(futures);

                      await SharePlus.instance.share(
                        ShareParams(
                          files: paths.map((path) => XFile(path)).toList(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Symbols.share),
              name: 'post.detail.share.image'.tr(),
            ),
          ],
        ),
      ),
      child: Scaffold(
        appBar: _buildAppBar(tasks),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;

                  if (_multiSelectController.multiSelectEnabled) {
                    _multiSelectController.disableMultiSelect();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const SizedBox.shrink(),
              ),
              ValueListenableBuilder(
                valueListenable: _multiSelectController.multiSelectNotifier,
                builder: (_, multiSelect, __) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => SizeTransition(
                    sizeFactor: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: multiSelect ? const SizedBox.shrink() : _buildFilter(),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: tasks.isNotEmpty
                      ? _buildList(tasks, config)
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                ref
                                    .watch(
                                      downloadFilterProvider(widget.filter),
                                    )
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
      ),
    );
  }

  AppBar _buildAppBar(List<TaskUpdate> tasks) {
    final group = ref.watch(downloadGroupProvider);
    final isDefaultGroup = group == FileDownloader.defaultGroup;

    return AppBar(
      title: ValueListenableBuilder(
        valueListenable: _multiSelectController.multiSelectNotifier,
        builder: (_, multiSelect, __) => multiSelect
            ? ValueListenableBuilder(
                valueListenable: _multiSelectController.selectedItemsNotifier,
                builder: (_, selected, __) => selected.isEmpty
                    ? const Text('Select items')
                    : Text('${selected.length} Items selected'),
              )
            : const Text(DownloadTranslations.downloadManagerTitle).tr(),
      ),
      actions: [
        if (isDefaultGroup)
          ValueListenableBuilder(
            valueListenable: _multiSelectController.multiSelectNotifier,
            builder: (_, multiSelect, __) => !multiSelect
                ? IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      openDownloadSettingsPage(ref);
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ValueListenableBuilder(
          valueListenable: _multiSelectController.multiSelectNotifier,
          builder: (_, multiSelect, __) => !multiSelect
              ? BooruPopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 'clear':
                        // clear default group only
                        ref.read(downloadTaskUpdatesProvider.notifier).clear(
                          FileDownloader.defaultGroup,
                          onFailed: () {
                            showSimpleSnackBar(
                              context: context,
                              content: const Text(
                                DownloadTranslations.downloadNothingToClear,
                              ).tr(),
                              duration: const Duration(seconds: 1),
                            );
                          },
                        );

                      case 'select':
                        _multiSelectController.enableMultiSelect();
                      default:
                    }
                  },
                  itemBuilder: {
                    'select': const Text('Select'),
                    if (isDefaultGroup) 'clear': const Text('Clear'),
                  },
                )
              : const SizedBox.shrink(),
        ),
        ValueListenableBuilder(
          valueListenable: _multiSelectController.multiSelectNotifier,
          builder: (_, multiSelect, __) => multiSelect
              ? IconButton(
                  onPressed: () => _multiSelectController.selectAll(
                    List.generate(
                      tasks.length,
                      (index) => index,
                    ),
                  ),
                  icon: const Icon(Symbols.select_all),
                )
              : const SizedBox.shrink(),
        ),
        ValueListenableBuilder(
          valueListenable: _multiSelectController.multiSelectNotifier,
          builder: (_, multiSelect, __) => multiSelect
              ? IconButton(
                  onPressed: () {
                    _multiSelectController.clearSelected();
                  },
                  icon: const Icon(Symbols.clear_all),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    final selectedFilter = ref.watch(downloadFilterProvider(widget.filter));
    return ChoiceOptionSelectorList(
      scrollController: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      searchable: false,
      options: _filterOptions,
      hasNullOption: false,
      optionLabelBuilder: (value) => value!.localize().tr(),
      onSelected: (value) {
        if (value == null) return;

        ref.read(downloadFilterProvider(widget.filter).notifier).state = value;
      },
      selectedOption: selectedFilter,
    );
  }

  Widget _buildList(List<TaskUpdate> tasks, BooruConfig config) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _DefaultSelectableItem(
          multiSelectController: _multiSelectController,
          index: index,
          item: SimpleDownloadTile(
            task: task,
            onTap: () {
              _multiSelectController.toggleSelection(index);
            },
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
              //FIXME: need to centralize the headers injection
              ref.invalidate(cachedBypassDdosHeadersProvider);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  final headers = {
                    AppHttpHeaders.userAgentHeader: ref.read(
                      userAgentProvider(
                        config.auth.booruType,
                      ),
                    ),
                    ...ref.read(
                      extraHttpHeaderProvider(config.auth),
                    ),
                    ...ref.read(
                      cachedBypassDdosHeadersProvider(
                        config.url,
                      ),
                    ),
                  };

                  FileDownloader().retryTask(
                    task.task,
                    headers: headers,
                  );
                },
              );
            },
            onCancel: () {
              FileDownloader().cancelTaskWithId(task.task.taskId);
            },
          ),
        );
      },
    );
  }
}

class _DefaultSelectableItem extends StatelessWidget {
  const _DefaultSelectableItem({
    required this.multiSelectController,
    required this.index,
    required this.item,
  });

  final MultiSelectController multiSelectController;
  final int index;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) => Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: multiSelect ? 48 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: multiSelect ? 1.0 : 0.0,
              child: multiSelect
                  ? ValueListenableBuilder(
                      valueListenable:
                          multiSelectController.selectedItemsNotifier,
                      builder: (_, selectedItems, __) => Checkbox(
                        value: selectedItems.contains(index),
                        onChanged: (value) {
                          if (value == null) return;
                          multiSelectController.toggleSelection(index);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: item,
          ),
        ],
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
    final failed = ref.watch(downloadTaskUpdatesProvider).failed(
          ref.watch(downloadGroupProvider),
        );
    final config = ref.watchConfig;

    return ref.watch(downloadFilterProvider(filter)) == DownloadFilter.failed &&
            failed.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: () {
                for (final task in failed) {
                  final dt = castOrNull<DownloadTask>(task.task);

                  if (dt == null) continue;
                  //FIXME: need to centralize the headers injection
                  ref.invalidate(cachedBypassDdosHeadersProvider);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      final headers = {
                        AppHttpHeaders.userAgentHeader: ref.read(
                          userAgentProvider(
                            config.auth.booruType,
                          ),
                        ),
                        ...ref.read(
                          extraHttpHeaderProvider(config.auth),
                        ),
                        ...ref.read(
                          cachedBypassDdosHeadersProvider(
                            config.url,
                          ),
                        ),
                      };

                      FileDownloader().retryTask(
                        dt,
                        headers: headers,
                      );
                    },
                  );
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

extension TaskExceptionX on TaskException {
  String? getErrorDescription() {
    final map = toJson();
    final responseCode = map['httpResponseCode'] as int?;

    return switch (responseCode) {
      416 =>
        'HTTP 416 Requested range not satisfiable, this is likely because you have an invalid download location or filename rule. Please change the download location or filename rule and try again.',
      _ => 'Failed: $description',
    };
  }
}

final _filePathProvider = FutureProvider.autoDispose
    .family<String, Task>((ref, task) => task.filePath());

class SimpleDownloadTile extends ConsumerWidget {
  const SimpleDownloadTile({
    required this.task,
    required this.onResume,
    required this.onPause,
    required this.onResumeFailed,
    required this.onRestart,
    required this.onCancel,
    this.onTap,
    super.key,
  });

  final TaskUpdate task;
  final void Function() onResume;
  final void Function() onPause;
  final void Function() onResumeFailed;
  final void Function() onRestart;
  final void Function() onCancel;
  final VoidCallback? onTap;

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
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _ModalOptions(task: task),
        );
      },
      onTap: onTap,
      onCancel: task.canCancel ? onCancel : null,
      builder: (_) => RawDownloadTile(
        fileName: task.task.filename,
        strikeThrough: task.isCanceled,
        color: task.isCanceled ? Theme.of(context).colorScheme.hintColor : null,
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

extension TaskUpdateX on TaskUpdate {
  int? get fileSize => switch (this) {
        final TaskStatusUpdate s => () {
            final defaultSize =
                DownloaderMetadata.fromJsonString(task.metaData).fileSize;
            final fileSizeString = s.responseHeaders.toOption().fold(
                  () => '',
                  (headers) => headers[AppHttpHeaders.contentLengthHeader],
                );
            final fileSize =
                fileSizeString != null ? int.tryParse(fileSizeString) : null;

            return fileSize ?? defaultSize;
          }(),
        final TaskProgressUpdate p => p.expectedFileSize,
      };
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
    final status = task.status;
    final exception = task.exception;
    final theme = Theme.of(context);

    return ReadMoreText(
      exception == null
          ? switch (status) {
              TaskStatus.complete =>
                ref.watch(_filePathProvider(task.task)).maybeWhen(
                      data: (data) => _prettifyFilePathIfNeeded(data),
                      orElse: () => '...',
                    ),
              _ => status.name.sentenceCase,
            }
          : '${exception.getErrorDescription()} ',
      trimLines: 1,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' more',
      trimExpandedText: ' less',
      lessStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      moreStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      style: TextStyle(
        color: theme.colorScheme.hintColor,
        fontSize: 12,
      ),
    );
  }
}

class _ModalOptions extends ConsumerWidget {
  const _ModalOptions({
    required this.task,
  });

  final TaskUpdate task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    final path = ref.watch(_filePathProvider(task.task)).valueOrNull;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const DragLine(),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text('post.detail.view_in_browser').tr(),
              onTap: () {
                launchExternalUrlString(task.task.url);
                navigator.pop();
              },
            ),
            if (path != null)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: const Text('post.detail.share.image').tr(),
                onTap: () {
                  navigator.pop();

                  SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(path)],
                      subject: task.task.filename,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
