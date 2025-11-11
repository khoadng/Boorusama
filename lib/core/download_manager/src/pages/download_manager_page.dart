// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../ddos/handler/providers.dart';
import '../../../downloads/background/types.dart';
import '../../../http/client/providers.dart';
import '../../../settings/routes.dart';
import '../../../widgets/default_selection_bar.dart';
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
  final _selectionModeController = SelectionModeController();

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
    _selectionModeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadFilteredProvider(widget.filter));
    final config = ref.watchConfig;
    final group = ref.watch(downloadGroupProvider);
    final isDefaultGroup = group == FileDownloader.defaultGroup;

    return SelectionMode(
      controller: _selectionModeController,
      scrollController: scrollController,
      child: Scaffold(
        appBar: DefaultSelectionAppBar(
          itemsCount: tasks.length,
          appBar: AppBar(
            title: Text(
              context.t.download.downloads,
            ),
            actions: [
              if (isDefaultGroup)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    openDownloadSettingsPage(ref);
                  },
                ),
              BooruPopupMenuButton(
                items: [
                  BooruPopupMenuItem(
                    title: Text(context.t.generic.action.select),
                    onTap: () {
                      _selectionModeController.enable();
                    },
                  ),
                  BooruPopupMenuItem(
                    title: Text(context.t.generic.action.clear),
                    onTap: () {
                      // clear default group only
                      ref
                          .read(downloadTaskUpdatesProvider.notifier)
                          .clear(
                            FileDownloader.defaultGroup,
                            onFailed: () {
                              showSimpleSnackBar(
                                context: context,
                                content: Text(
                                  context.t.download.nothing_to_clear,
                                ),
                                duration: const Duration(seconds: 1),
                              );
                            },
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectionConsumer(
                    builder: (_, controller, _) {
                      final multiSelect = controller.isActive;
                      return AnimatedSwitcher(
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
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: tasks.isNotEmpty
                          ? SelectionCanvas(
                              child: _buildList(tasks, config),
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    ref
                                        .watch(
                                          downloadFilterProvider(widget.filter),
                                        )
                                        .emptyLocalize(context),
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
              SelectionConsumer(
                builder: (context, controller, _) {
                  final selectedItems = controller.selectedFrom(tasks).toList();

                  if (!controller.isActive) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MultiSelectionActionBar(
                      children: [
                        MultiSelectButton(
                          onPressed: selectedItems.isNotEmpty
                              ? () async {
                                  final futures = selectedItems
                                      .map(
                                        (task) => task.task.filePath(),
                                      )
                                      .toList();
                                  final paths = await Future.wait(futures);

                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: paths
                                          .map((path) => XFile(path))
                                          .toList(),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Symbols.share),
                          name: context.t.post.detail.share.image,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<TaskUpdate> tasks, BooruConfig config) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return DownloadSelectableItem(
          index: index,
          item: SimpleDownloadTile(
            task: task,
            onTap: () {
              if (_selectionModeController.isActive) {
                _selectionModeController.toggleItem(index);
              }
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
