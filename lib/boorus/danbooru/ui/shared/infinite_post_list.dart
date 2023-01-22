// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/post_grid.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';

class InfinitePostList extends StatefulWidget {
  const InfinitePostList({
    super.key,
    required this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.refreshController,
  });

  final VoidCallback onLoadMore;
  final void Function(RefreshController controller)? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final RefreshController? refreshController;

  @override
  State<InfinitePostList> createState() => _InfinitePostListState();
}

class _InfinitePostListState extends State<InfinitePostList> {
  var selectedPosts = <Post>[];
  var multiSelect = false;
  late final AutoScrollController _autoScrollController;
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
    _refreshController = widget.refreshController ?? RefreshController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    if (widget.refreshController == null) {
      _refreshController.dispose();
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
            DownloadProviderWidget(
              builder: (context, download) => IconButton(
                onPressed: selectedPosts.isNotEmpty
                    ? () {
                        // ignore: prefer_foreach
                        for (final p in selectedPosts) {
                          download(p);
                        }

                        _endMultiSelect();
                      }
                    : null,
                icon: const Icon(Icons.download),
              ),
            ),
          ],
        ),
        topBuilder: () => AppBar(
          leading: IconButton(
            onPressed: () => _endMultiSelect(),
            icon: const Icon(Icons.close),
          ),
          title: selectedPosts.isEmpty
              ? const Text('Select items')
              : Text('${selectedPosts.length} Items selected'),
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
        refreshController: _refreshController,
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

  void _endMultiSelect() {
    setState(() {
      multiSelect = false;
      selectedPosts.clear();
    });
  }
}
