// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

// Flutter imports:

class FavoriteGroupDetailsPage extends ConsumerStatefulWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.group,
    required this.postIds,
  });

  final FavoriteGroup group;
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
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) => getPostsFromIdQueue(widget.postIds),
    refresher: () => getPostsFromIdQueue(widget.postIds),
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
      items = controller.items;
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
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      floatingActionButton: editing
          ? FloatingActionButton(
              onPressed: () {
                _aggregate(config);
                setState(() => editing = false);
              },
              child: const Icon(Icons.save),
            )
          : null,
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.group.name.replaceUnderscoreWithSpace()),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        actions: [
          if (!editing)
            IconButton(
              onPressed: () {
                goToSearchPage(
                  context,
                  tag: widget.group.getQueryString(),
                );
              },
              icon: const Icon(Icons.search),
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
              icon: const Icon(Icons.download),
            ),
          if (!editing)
            IconButton(
              onPressed: () {
                setState(() {
                  editing = true;
                  commands.clear();
                });
              },
              icon: const Icon(Icons.edit),
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
          : Column(
              children: [
                if (editing)
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Drag and drop to determine ordering.'),
                      ),
                      ButtonBar(
                        children: [
                          IconButton(
                            onPressed: rowCountEditMode > 1
                                ? () => setState(() => rowCountEditMode -= 1)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: rowCountEditMode <
                                    _sizeToGridCount(
                                      Screen.of(context).nextBreakpoint(),
                                    )
                                ? () => setState(() => rowCountEditMode += 1)
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                Expanded(
                  child: InfiniteLoadList(
                    scrollController: scrollController,
                    onLoadMore: () => controller.fetchMore(),
                    enableRefresh: false,
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
                                  commands.add([false, oldIndex, newIndex, 0]);
                                });
                              }
                            },
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                    hasAccount: config.hasLoginDetails(),
                                  ),
                                  child: child,
                                ),
                                child: DanbooruImageGridItem(
                                  image: BooruImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        post.thumbnailFromSettings(settings),
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
                                            scrollController: scrollController,
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
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      controller.remove([post.id], (e) => e.id);
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
    );
  }
}

int _sizeToGridCount(ScreenSize size) {
  switch (size) {
    case ScreenSize.small:
      return 2;
    case ScreenSize.medium:
      return 4;
    case ScreenSize.large:
      return 6;
    case ScreenSize.veryLarge:
      return 8;
  }
}
