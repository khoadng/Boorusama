// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:boorusama/core/ui/widgets/circular_icon_button.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

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
    with
        DanbooruPostTransformMixin,
        DanbooruPostServiceProviderMixin,
        DanbooruFavoriteGroupPostMixin {
  List<List<Object>> commands = [];
  bool editing = false;
  final AutoScrollController scrollController = AutoScrollController();
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) => getPostsFromIdQueue(widget.postIds).then(transform),
    refresher: () => getPostsFromIdQueue(widget.postIds).then(transform),
  );
  int rowCountEditMode = 2;

  List<DanbooruPost> items = [];
  bool refreshing = false;
  bool loading = false;
  bool hasMore = false;

  @override
  DanbooruPostRepository get postRepository =>
      context.read<DanbooruPostRepository>();

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

  void _aggregate() {
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

    context.read<FavoriteGroupsBloc>().add(FavoriteGroupsEdited(
          group: widget.group,
          initialIds: ids.join(' '),
          refreshPreviews: true,
        ));
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
    final authState = ref.watch(authenticationProvider);

    return Scaffold(
      floatingActionButton: editing
          ? FloatingActionButton(
              onPressed: () {
                _aggregate();
                setState(() => editing = false);
              },
              child: const Icon(Icons.save),
            )
          : null,
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.group.name.replaceAll('_', ' ')),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: BlocBuilder<FavoritePostCubit, FavoritePostState>(
                    buildWhen: (previous, current) =>
                        current is FavoritePostListSuccess,
                    builder: (context, favoriteState) {
                      return InfiniteLoadList(
                        scrollController: scrollController,
                        onLoadMore: () => controller.fetchMore(),
                        enableRefresh: false,
                        enableLoadMore: hasMore,
                        builder: (context, scrollController) {
                          final count =
                              _sizeToGridCount(Screen.of(context).size);

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
                              crossAxisCount:
                                  editing ? rowCountEditMode : count,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemBuilder: (context, index) {
                              final post = items[index];

                              var isFaved = false;
                              if (favoriteState is FavoritePostListSuccess) {
                                isFaved =
                                    favoriteState.favorites[post.id] ?? false;
                              }

                              return Stack(
                                key: ValueKey(index),
                                children: [
                                  ConditionalParentWidget(
                                    condition: !editing,
                                    conditionalBuilder: (child) =>
                                        ContextMenuRegion(
                                      contextMenu: DanbooruPostContextMenu(
                                        post: post,
                                        hasAccount: authState is Authenticated,
                                      ),
                                      child: child,
                                    ),
                                    child: ImageGridItem(
                                      hideOverlay: editing,
                                      isFaved: isFaved,
                                      enableFav: authState is Authenticated,
                                      onFavToggle: (isFaved) async {
                                        final favoritePostCubit =
                                            context.read<FavoritePostCubit>();
                                        if (!isFaved) {
                                          await favoritePostCubit
                                              .removeFavorite(post.id);
                                        } else {
                                          await favoritePostCubit
                                              .addFavorite(post.id);
                                        }
                                      },
                                      autoScrollOptions: AutoScrollOptions(
                                        controller: scrollController,
                                        index: index,
                                      ),
                                      onTap: !editing
                                          ? () => goToDetailPage(
                                                context: context,
                                                posts: items,
                                                initialIndex: index,
                                                scrollController:
                                                    scrollController,
                                              )
                                          : null,
                                      image: BooruImage(
                                        fit: BoxFit.cover,
                                        imageUrl: post.isAnimated
                                            ? post.thumbnailImageUrl
                                            : post.sampleImageUrl,
                                        placeholderUrl: post.thumbnailImageUrl,
                                      ),
                                      isAnimated: post.isAnimated,
                                      isTranslated: post.isTranslated,
                                      hasComments: post.hasComment,
                                      hasParentOrChildren:
                                          post.hasParentOrChildren,
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
