// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';

class ExplorePostGrid extends StatelessWidget {
  const ExplorePostGrid({
    Key? key,
    required this.date,
    required this.scale,
    required this.status,
    required this.posts,
    required this.onLoadMore,
    required this.onRefresh,
    required this.controller,
    required this.scrollController,
    required this.hasMore,
    required this.header,
  }) : super(key: key);

  final DateTime date;
  final TimeScale scale;
  final LoadStatus status;
  final List<PostData> posts;
  final void Function(DateTime date, TimeScale scale) onLoadMore;
  final void Function(DateTime date, TimeScale scale) onRefresh;
  final RefreshController controller;
  final AutoScrollController scrollController;
  final bool hasMore;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    return InfiniteLoadList(
      enableLoadMore: hasMore,
      scrollController: scrollController,
      refreshController: controller,
      onLoadMore: () => onLoadMore(date, scale),
      onRefresh: (controller) {
        onRefresh(date, scale);
        Future.delayed(const Duration(milliseconds: 500),
            () => controller.refreshCompleted());
      },
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: [
          SliverToBoxAdapter(
            child: header,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: mapLoadStatusToWidget(context, status, controller),
          ),
          if (status == LoadStatus.loading)
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 20, top: 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget mapLoadStatusToWidget(
    BuildContext context,
    LoadStatus status,
    AutoScrollController controller,
  ) {
    if (status == LoadStatus.initial) {
      return const SliverPostGridPlaceHolder();
    } else if (status == LoadStatus.success) {
      if (posts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(child: Text('No data')),
        );
      }
      return SliverPostGrid(
        posts: posts,
        scrollController: controller,
        onTap: (post, index) => AppRouter.router.navigateTo(
          context,
          '/post/detail',
          routeSettings: RouteSettings(
            arguments: [
              posts,
              index,
              controller,
            ],
          ),
        ),
        onFavoriteUpdated: (postId, value) => context
            .read<PostBloc>()
            .add(PostFavoriteUpdated(postId: postId, favorite: value)),
      );
    } else if (status == LoadStatus.loading) {
      if (posts.isEmpty) {
        return const SliverPostGridPlaceHolder();
      } else {
        return SliverPostGrid(
          posts: posts,
          scrollController: controller,
          onTap: (post, index) => AppRouter.router.navigateTo(
            context,
            '/post/detail',
            routeSettings: RouteSettings(
              arguments: [
                posts,
                index,
                controller,
              ],
            ),
          ),
          onFavoriteUpdated: (postId, value) => context
              .read<PostBloc>()
              .add(PostFavoriteUpdated(postId: postId, favorite: value)),
        );
      }
    } else {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('Something went wrong'),
        ),
      );
    }
  }
}
