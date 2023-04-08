// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/danbooru_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/multi_selectable_mixin.dart';

class InfinitePostList<T> extends StatefulWidget {
  const InfinitePostList({
    super.key,
    required this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.refreshController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    required this.state,
  });

  final VoidCallback onLoadMore;
  final void Function(RefreshController controller)? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final RefreshController? refreshController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final PostState<DanbooruPostData, T> state;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  State<InfinitePostList> createState() => _InfinitePostListState();
}

class _InfinitePostListState<T> extends State<InfinitePostList<T>>
    with MultiSelectableMixin<InfinitePostList<T>, Post> {
  late final AutoScrollController _autoScrollController;
  late final RefreshController _refreshController;

  PostState<DanbooruPostData, T> get state => widget.state;

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

  //TODO: clear selected when refreshing
  @override
  Widget build(BuildContext context) {
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: InfiniteLoadListScrollView(
        bottomBuilder: () =>
            widget.multiSelectActions?.call(
              selected,
              endMultiSelect,
            ) ??
            DefaultMultiSelectionActions(
              selectedPosts: selected,
              endMultiSelect: endMultiSelect,
            ),
        topBuilder: () => AppBar(
          leading: IconButton(
            onPressed: endMultiSelect,
            icon: const Icon(Icons.close),
          ),
          title: selected.isEmpty
              ? const Text('Select items')
              : Text('${selected.length} Items selected'),
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
            state: state,
            scrollController: controller,
            usePlaceholder: true,
            onPostSelectChanged: (post, selected) {
              if (selected) {
                addSelected(post);
              } else {
                removeSelected(post);
              }
            },
            multiSelect: multiSelect,
            contextMenuBuilder: (post) =>
                widget.contextMenuBuilder?.call(post, enableMultiSelect) ??
                DefaultPostContextMenu(
                  hasAccount: authState is Authenticated,
                  onMultiSelect: enableMultiSelect,
                  post: post,
                ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (multiSelect) {
      endMultiSelect();

      return false;
    } else {
      return true;
    }
  }
}

// ignore: prefer-single-widget-per-file
class DefaultMultiSelectionActions extends StatelessWidget {
  const DefaultMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final List<Post> selectedPosts;
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

  final List<Post> selectedPosts;
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
