// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/danbooru_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/domain/posts/post.dart' as core;
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
    this.contextMenuBuilder,
    this.multiSelectActions,
  });

  final VoidCallback onLoadMore;
  final void Function(RefreshController controller)? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final RefreshController? refreshController;
  final Widget Function(core.Post post, void Function() next)?
      contextMenuBuilder;

  final Widget Function(
    List<core.Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  State<InfinitePostList> createState() => _InfinitePostListState();
}

class _InfinitePostListState extends State<InfinitePostList> {
  var selectedPosts = <core.Post>[];
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
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.refreshing) {
          setState(() {
            selectedPosts.clear();
          });
        }
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: InfiniteLoadListScrollView(
          bottomBuilder: () =>
              widget.multiSelectActions?.call(
                selectedPosts,
                _endMultiSelect,
              ) ??
              DefaultMultiSelectionActions(
                selectedPosts: selectedPosts,
                endMultiSelect: _endMultiSelect,
              ),
          topBuilder: () => AppBar(
            leading: IconButton(
              onPressed: _endMultiSelect,
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
            DanbooruPostGrid(
              scrollController: controller,
              usePlaceholder: true,
              posts: state.posts,
              status: state.status,
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
              contextMenuBuilder: (post) =>
                  widget.contextMenuBuilder?.call(post, _enableMultiSelect) ??
                  DefaultPostContextMenu(
                    hasAccount: authState is Authenticated,
                    onMultiSelect: _enableMultiSelect,
                    post: post,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (multiSelect) {
      _endMultiSelect();

      return false;
    } else {
      return true;
    }
  }

  void _enableMultiSelect() => setState(() {
        multiSelect = true;
      });

  void _endMultiSelect() {
    setState(() {
      multiSelect = false;
      selectedPosts.clear();
    });
  }
}

// ignore: prefer-single-widget-per-file
class DefaultMultiSelectionActions extends StatelessWidget {
  const DefaultMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final List<core.Post> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context) {
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return ButtonBar(
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

                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.download),
          ),
        ),
        if (authenticationState is Authenticated)
          IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () async {
                    final shouldEnd = await goToAddToFavoriteGroupSelectionPage(
                      context,
                      selectedPosts,
                    );
                    if (shouldEnd != null && shouldEnd) {
                      endMultiSelect();
                    }
                  }
                : null,
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }
}

// ignore: prefer-single-widget-per-file
class FavoriteGroupMultiSelectionActions extends StatelessWidget {
  const FavoriteGroupMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
    required this.onRemoveFromFavGroup,
  });

  final List<core.Post> selectedPosts;
  final void Function() endMultiSelect;
  final void Function() onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context) {
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return ButtonBar(
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

                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.download),
          ),
        ),
        if (authenticationState is Authenticated)
          IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () {
                    onRemoveFromFavGroup();
                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.remove),
          ),
      ],
    );
  }
}
