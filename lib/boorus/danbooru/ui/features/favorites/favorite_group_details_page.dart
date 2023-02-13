// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/common/collection_utils.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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

class _FavoriteGroupDetailsPageState extends State<FavoriteGroupDetailsPage> {
  bool changed = false;
  List<List<Object>> commands = [];

  void _aggregate() {
    final ids = widget.group.postIds;
    for (final cmd in commands) {
      final toIndex = cmd[1] as int;
      final fromIndex = cmd.first as int;
      final item = ids.removeAt(fromIndex);
      ids.insert(toIndex, item);
    }

    context.read<FavoriteGroupsBloc>().add(FavoriteGroupsEdited(
          group: widget.group,
          initialIds: ids.join(' '),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select((PostBloc bloc) => bloc.state);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name.replaceAll('_', ' ')),
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              goToSearchPage(
                context,
                tag: widget.group.getQueryString(),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              goToBulkDownloadPage(
                context,
                [widget.group.getQueryString()],
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      floatingActionButton: changed
          ? FloatingActionButton(
              onPressed: () {
                _aggregate();
                setState(() {
                  changed = false;
                });
              },
              child: const Icon(Icons.save),
            )
          : null,
      body: state.refreshing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : InfiniteLoadList(
              onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                    tags: '',
                    fetcher: FavoriteGroupPostFetcher(
                      ids: widget.postIds.dequeue(20),
                    ),
                  )),
              enableRefresh: false,
              enableLoadMore: state.hasMore,
              builder: (context, controller) {
                return ReorderableGridView.builder(
                  controller: controller,
                  itemCount: state.data.length,
                  onReorder: (oldIndex, newIndex) =>
                      context.read<PostBloc>().add(PostMovedAndInserted(
                            fromIndex: oldIndex,
                            toIndex: newIndex,
                            onSuccess: () {
                              setState(() {
                                commands.add([oldIndex, newIndex]);
                                changed = true;
                              });
                            },
                          )),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final post = state.data[index].post;

                    return GestureDetector(
                      key: ValueKey(index),
                      onTap: () => goToDetailPage(
                        context: context,
                        posts: state.data,
                        initialIndex: index,
                      ),
                      child: BooruImage(
                        fit: BoxFit.cover,
                        imageUrl: post.normalImageUrl,
                        placeholderUrl: post.previewImageUrl,
                        aspectRatio: post.aspectRatio,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
