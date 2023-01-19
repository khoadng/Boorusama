import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/post_grid.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfinitePostList extends StatefulWidget {
  const InfinitePostList({
    super.key,
    required this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
  });

  final VoidCallback onLoadMore;
  final void Function(RefreshController controller)? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;

  @override
  State<InfinitePostList> createState() => _InfinitePostListState();
}

class _InfinitePostListState extends State<InfinitePostList> {
  var selectedPosts = <Post>[];
  var multiSelect = false;
  late final AutoScrollController _autoScrollController;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostBloc>().state;

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.refreshing) {
          setState(() {
            selectedPosts.clear();
          });
        }
      },
      child: InfiniteLoadListScrollView(
        bottomBuilder: () => ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () =>
                  print('download ${selectedPosts.map((e) => e.id)}'),
              icon: const Icon(Icons.download),
            ),
            IconButton(
              onPressed: () => print('share'),
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        topBuilder: () => AppBar(
          leading: IconButton(
            onPressed: () => setState(() {
              multiSelect = false;
              selectedPosts.clear();
            }),
            icon: const Icon(Icons.close),
          ),
          title: selectedPosts.isEmpty
              ? const Text('Select items')
              : Text('${selectedPosts.length} Items selected'),
          // actions: [
          //   IconButton(
          //     onPressed: () => print('select all'),
          //     icon: const Icon(Icons.done_all),
          //   ),
          // ],
        ),
        enableRefresh: widget.onRefresh != null,
        multiSelect: multiSelect,
        isLoading: state.loading,
        enableLoadMore: state.hasMore,
        onLoadMore: () => widget.onLoadMore.call(),
        onRefresh: (controller) {
          widget.onRefresh?.call(controller);
          Future.delayed(
            const Duration(seconds: 1),
            () => controller.refreshCompleted(),
          );
        },
        scrollController: _autoScrollController,
        sliverBuilder: (controller) => [
          if (widget.sliverHeaderBuilder != null)
            ...widget.sliverHeaderBuilder!(context),
          PostGrid(
            controller: controller,
            onPostSelectChanged: (post, selected) {
              setState(() {
                if (selected) {
                  selectedPosts.add(post);
                } else {
                  selectedPosts.remove(post);
                }
              });
            },
            multiSelect: multiSelect,
            onMultiSelect: () => setState(() {
              multiSelect = true;
            }),
          ),
        ],
      ),
    );
  }
}
