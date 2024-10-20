// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../posts/posts.dart';
import 'favorite_groups.dart';

// Flutter imports:

class FavoriteGroupDetailsPage extends ConsumerStatefulWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.group,
    required this.postIds,
  });

  final DanbooruFavoriteGroup group;
  final Queue<int> postIds;

  @override
  ConsumerState<FavoriteGroupDetailsPage> createState() =>
      _FavoriteGroupDetailsPageState();
}

class _FavoriteGroupDetailsPageState
    extends ConsumerState<FavoriteGroupDetailsPage>
    with DanbooruFavoriteGroupPostMixin {
  List<List<Object>> commands = [];
  bool editing = false;
  final AutoScrollController scrollController = AutoScrollController();
  //TODO: this part might be broken after the new filtering system, need to check
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) => getPostsFromIdQueue(widget.postIds),
    blacklistedTagsFetcher: () =>
        ref.read(blacklistTagsProvider(ref.watchConfig).future),
    refresher: () => getPostsFromIdQueue(widget.postIds),
    mountedChecker: () => mounted,
  );

  int rowCountEditMode = 2;

  List<DanbooruPost> items = [];
  bool refreshing = false;
  bool loading = false;
  bool hasMore = false;

  @override
  PostRepository<DanbooruPost> get postRepository =>
      ref.read(danbooruPostRepoProvider(ref.readConfig));

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
    controller.refresh();
  }

  void _onControllerChanged() {
    setState(() {
      items = controller.items.toList();
      hasMore = controller.hasMore;
      loading = controller.loading;
      refreshing = controller.refreshing;
    });
  }

  void _aggregate(BooruConfig config) {
    final ids = widget.group.postIds;
    for (final cmd in commands) {
      final toIndex = cmd[2] as int;
      final fromIndex = cmd[1] as int;
      final deleteCmd = cmd.first as bool;
      final deleteTarget = cmd[3] as int;

      if (deleteCmd) {
        ids.remove(deleteTarget);
      } else {
        final item = ids.removeAt(fromIndex);
        ids.insert(toIndex, item);
      }
    }

    ref.read(danbooruFavoriteGroupsProvider(config).notifier).edit(
          group: widget.group,
          initialIds: ids.join(' '),
        );
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final settings = ref.watch(imageListingSettingsProvider);

    return Scaffold(
      floatingActionButton: editing
          ? FloatingActionButton(
              onPressed: () {
                _aggregate(config);
                setState(() => editing = false);
              },
              child: const Icon(Symbols.save),
            )
          : null,
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.group.name.replaceUnderscoreWithSpace()),
        actions: [
          if (!editing)
            IconButton(
              onPressed: () {
                goToSearchPage(
                  context,
                  tag: widget.group.getQueryString(),
                );
              },
              icon: const Icon(Symbols.search),
            ),
          if (!editing)
            IconButton(
              onPressed: () {
                goToBulkDownloadPage(
                  context,
                  [widget.group.getQueryString()],
                  ref: ref,
                );
              },
              icon: const Icon(Symbols.download),
            ),
          if (!editing)
            IconButton(
              onPressed: () {
                setState(() {
                  editing = true;
                  commands.clear();
                });
              },
              icon: const Icon(
                Symbols.edit,
                fill: 1,
              ),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  editing = false;
                  commands.clear();
                });
              },
              child: const Text('generic.action.cancel').tr(),
            ),
        ],
      ),
      body: refreshing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (editing)
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Drag and drop to determine ordering.'),
                        ),
                        GridSizeAdjustmentButtons(
                          minCount: 2,
                          maxCount: _sizeToGridCount(
                            Screen.of(context).nextBreakpoint(),
                          ),
                          count: rowCountEditMode,
                          onAdded: (count) =>
                              setState(() => rowCountEditMode = count + 1),
                          onDecreased: (count) =>
                              setState(() => rowCountEditMode = count - 1),
                        ),
                      ],
                    ),
                  Expanded(
                    child: InfiniteLoadList(
                      scrollController: scrollController,
                      onLoadMore: () => controller.fetchMore(),
                      enableLoadMore: hasMore,
                      builder: (context, scrollController) {
                        final count = _sizeToGridCount(Screen.of(context).size);

                        return ReorderableGridView.builder(
                          controller: scrollController,
                          dragEnabled: editing,
                          itemCount: items.length,
                          onReorder: (oldIndex, newIndex) {
                            controller.moveAndInsert(
                              fromIndex: oldIndex,
                              toIndex: newIndex,
                              onSuccess: () {
                                if (oldIndex != newIndex) {
                                  setState(() {
                                    commands
                                        .add([false, oldIndex, newIndex, 0]);
                                  });
                                }
                              },
                            );
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: editing ? rowCountEditMode : count,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemBuilder: (context, index) {
                            final post = items[index];

                            return Stack(
                              key: ValueKey(index),
                              children: [
                                ConditionalParentWidget(
                                  condition: !editing,
                                  conditionalBuilder: (child) =>
                                      ContextMenuRegion(
                                    contextMenu: DanbooruPostContextMenu(
                                      post: post,
                                    ),
                                    child: child,
                                  ),
                                  child: DanbooruImageGridItem(
                                    image: BooruImage(
                                      fit: BoxFit.cover,
                                      imageUrl: post.thumbnailFromImageQuality(
                                          settings.imageQuality),
                                      placeholderUrl: post.thumbnailImageUrl,
                                    ),
                                    enableFav: config.hasLoginDetails(),
                                    hideOverlay: editing,
                                    autoScrollOptions: AutoScrollOptions(
                                      controller: scrollController,
                                      index: index,
                                    ),
                                    post: post,
                                    onTap: !editing
                                        ? () => goToPostDetailsPage(
                                              context: context,
                                              posts: items,
                                              initialIndex: index,
                                              scrollController:
                                                  scrollController,
                                            )
                                        : null,
                                  ),
                                ),
                                if (editing)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircularIconButton(
                                      padding: const EdgeInsets.all(4),
                                      icon: const Icon(
                                        Symbols.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        controller
                                            .remove([post.id], (e) => e.id);
                                        commands.add([true, 0, 0, post.id]);
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

int _sizeToGridCount(ScreenSize size) => switch (size) {
      ScreenSize.small => 2,
      ScreenSize.medium => 4,
      ScreenSize.large => 6,
      ScreenSize.veryLarge => 8
    };
