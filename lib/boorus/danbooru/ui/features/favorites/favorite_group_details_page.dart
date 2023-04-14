// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class FavoriteGroupDetailsPage extends StatefulWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.group,
    required this.postIds,
  });

  final FavoriteGroup group;
  final Queue<int> postIds;

  @override
  State<FavoriteGroupDetailsPage> createState() =>
      _FavoriteGroupDetailsPageState();
}

class _FavoriteGroupDetailsPageState extends State<FavoriteGroupDetailsPage>
    with DanbooruFavoriteGroupPostCubitMixin {
  List<List<Object>> commands = [];
  bool editing = false;
  final AutoScrollController scrollController = AutoScrollController();
  int rowCountEditMode = 2;

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
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state =
        context.select((DanbooruFavoriteGroupPostCubit bloc) => bloc.state);
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

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
      body: state.refreshing
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
                    onLoadMore: () => fetch(),
                    enableRefresh: false,
                    enableLoadMore: state.hasMore,
                    builder: (context, controller) {
                      final count = _sizeToGridCount(Screen.of(context).size);

                      return ReorderableGridView.builder(
                        controller: controller,
                        dragEnabled: editing,
                        itemCount: state.data.length,
                        onReorder: (oldIndex, newIndex) {
                          moveAndInsert(
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
                          final post = state.data[index];

                          return Stack(
                            key: ValueKey(index),
                            children: [
                              ConditionalParentWidget(
                                condition: !editing,
                                conditionalBuilder: (child) =>
                                    ContextMenuRegion(
                                  contextMenu: DefaultPostContextMenu(
                                    post: post.post,
                                    hasAccount: authState is Authenticated,
                                  ),
                                  child: child,
                                ),
                                child: ImageGridItem(
                                  hideOverlay: editing,
                                  isFaved: post.isFavorited,
                                  enableFav: authState is Authenticated,
                                  onFavToggle: (isFaved) async {
                                    // final bloc = context.read<PostBloc>();
                                    final _ = await _getFavAction(
                                      context,
                                      !isFaved,
                                      post.post.id,
                                    );
                                    // if (success) {
                                    //   bloc.add(
                                    //     PostFavoriteUpdated(
                                    //       postId: post.post.id,
                                    //       favorite: isFaved,
                                    //     ),
                                    //   );
                                    // }
                                  },
                                  autoScrollOptions: AutoScrollOptions(
                                    controller: scrollController,
                                    index: index,
                                  ),
                                  onTap: !editing
                                      ? () => goToDetailPage(
                                            context: context,
                                            posts: state.data,
                                            initialIndex: index,
                                            scrollController: scrollController,
                                          )
                                      : null,
                                  image: BooruImage(
                                    fit: BoxFit.cover,
                                    imageUrl: post.post.isAnimated
                                        ? post.post.thumbnailImageUrl
                                        : post.post.sampleImageUrl,
                                    placeholderUrl: post.post.thumbnailImageUrl,
                                  ),
                                  isAnimated: post.post.isAnimated,
                                  isTranslated: post.post.isTranslated,
                                  hasComments: post.post.hasComment,
                                  hasParentOrChildren:
                                      post.post.hasParentOrChildren,
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
                                      remove([post.post.id]);
                                      commands.add([true, 0, 0, post.post.id]);
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

  Future<bool> _getFavAction(BuildContext context, bool isFaved, int postId) {
    return isFaved
        ? context.read<FavoritePostRepository>().removeFromFavorites(postId)
        : context.read<FavoritePostRepository>().addToFavorites(postId);
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
