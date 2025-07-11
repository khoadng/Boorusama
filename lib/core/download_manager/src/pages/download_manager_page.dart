// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../http/providers.dart';
import '../../../settings/routes.dart';
import '../../../widgets/widgets.dart';
import '../../types.dart';
import '../l10n.dart';
import '../providers/download_task_updates_notifier.dart';
import '../providers/internal_providers.dart';
import '../widgets/download_filter_options.dart';
import '../widgets/download_selectable_item.dart';
import '../widgets/retry_all_failed_button.dart';
import '../widgets/simple_download_tile.dart';

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
        downloadGroupProvider.overrideWithValue(
          group ?? FileDownloader.defaultGroup,
        ),
      ],
      child: DownloadManagerPage(
        filter: filter,
      ),
    );
  }
}

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
      final index = kFilterOptions.indexOf(filterType);

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
        builder: (_, selectedItems, _) => MultiSelectionActionBar(
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
              name: context.t.post.detail.share.image,
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
                builder: (_, multiSelect, _) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => SizeTransition(
                    sizeFactor: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: multiSelect
                      ? const SizedBox.shrink()
                      : DownloadFilterOptions(
                          scrollController: scrollController,
                          filter: widget.filter,
                        ),
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
        builder: (_, multiSelect, _) => multiSelect
            ? ValueListenableBuilder(
                valueListenable: _multiSelectController.selectedItemsNotifier,
                builder: (_, selected, _) => selected.isEmpty
                    ? Text('Select items'.hc)
                    : Text('${selected.length} Items selected'.hc),
              )
            : Text(DownloadTranslations.downloadManagerTitle),
      ),
      actions: [
        if (isDefaultGroup)
          ValueListenableBuilder(
            valueListenable: _multiSelectController.multiSelectNotifier,
            builder: (_, multiSelect, _) => !multiSelect
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
          builder: (_, multiSelect, _) => !multiSelect
              ? BooruPopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 'clear':
                        // clear default group only
                        ref
                            .read(downloadTaskUpdatesProvider.notifier)
                            .clear(
                              FileDownloader.defaultGroup,
                              onFailed: () {
                                showSimpleSnackBar(
                                  context: context,
                                  content: Text(
                                    DownloadTranslations.downloadNothingToClear,
                                  ),
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
                    'select': Text('Select'.hc),
                    if (isDefaultGroup) 'clear': Text('Clear'.hc),
                  },
                )
              : const SizedBox.shrink(),
        ),
        ValueListenableBuilder(
          valueListenable: _multiSelectController.multiSelectNotifier,
          builder: (_, multiSelect, _) => multiSelect
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
          builder: (_, multiSelect, _) => multiSelect
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

  Widget _buildList(List<TaskUpdate> tasks, BooruConfig config) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return DownloadSelectableItem(
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
                  final headers = ref.read(httpHeadersProvider(config.auth));

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
