// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_post_context_menu.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart' as core;
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/multi_selectable_mixin.dart';
import 'package:boorusama/core/ui/post_grid.dart';

class GelbooruInfinitePostList extends StatefulWidget {
  const GelbooruInfinitePostList({
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
  State<GelbooruInfinitePostList> createState() => _InfinitePostListState();
}

class _InfinitePostListState extends State<GelbooruInfinitePostList>
    with MultiSelectableMixin<GelbooruInfinitePostList, Post> {
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
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return BlocListener<GelbooruPostBloc, GelbooruPostState>(
      listener: (context, state) {
        if (state.refreshing) {
          clearSelected();
        }
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocBuilder<GelbooruPostBloc, GelbooruPostState>(
          buildWhen: (previous, current) => !current.loading,
          builder: (context, state) {
            return InfiniteLoadListScrollView(
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
                PostGrid(
                  enableFavorite: false,
                  controller: controller,
                  posts: state.data,
                  status: state.refreshing
                      ? LoadStatus.initial
                      : state.loading
                          ? LoadStatus.loading
                          : LoadStatus.success,
                  onPostSelectChanged: (post, selected) {
                    if (selected) {
                      addSelected(post);
                    } else {
                      removeSelected(post);
                    }
                  },
                  multiSelect: multiSelect,
                  contextMenuBuilder: (post) =>
                      widget.contextMenuBuilder
                          ?.call(post, enableMultiSelect) ??
                      GelbooruPostContextMenu(
                        hasAccount: authState is Authenticated,
                        onMultiSelect: enableMultiSelect,
                        post: post,
                      ),
                  isFavorite: (post) => false,
                  // ignore: no-empty-block
                  onFavoriteTap: (post, isFav) {},
                  onTap: (int index) {
                    goToGelbooruPostDetailsPage(
                      context: context,
                      posts: state.data,
                      initialIndex: index,
                    );
                  },
                ),
              ],
            );
          },
        ),
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

  final List<core.Post> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context) {
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
