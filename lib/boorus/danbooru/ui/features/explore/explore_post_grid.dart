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
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'package:boorusama/core/ui/no_data_box.dart';

class ExplorePostGrid extends StatelessWidget {
  const ExplorePostGrid({
    super.key,
    required this.date,
    required this.scale,
    required this.status,
    required this.posts,
    required this.onLoadMore,
    required this.onRefresh,
    required this.controller,
    required this.scrollController,
    required this.hasMore,
    required this.headers,
    required this.isLoading,
  });

  final DateTime date;
  final TimeScale scale;
  final LoadStatus status;
  final List<PostData> posts;
  final void Function(DateTime date, TimeScale scale) onLoadMore;
  final void Function(DateTime date, TimeScale scale) onRefresh;
  final RefreshController controller;
  final AutoScrollController scrollController;
  final bool hasMore;
  final bool isLoading;
  final List<Widget> headers;

  @override
  Widget build(BuildContext context) {
    return InfiniteLoadListScrollView(
      isLoading: isLoading,
      enableLoadMore: hasMore,
      scrollController: scrollController,
      refreshController: controller,
      onLoadMore: () => onLoadMore(date, scale),
      onRefresh: (controller) {
        onRefresh(date, scale);
        Future.delayed(
          const Duration(milliseconds: 500),
          () => controller.refreshCompleted(),
        );
      },
      sliverBuilder: (controller) => [
        ...headers.map((header) => SliverToBoxAdapter(child: header)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          sliver: mapLoadStatusToWidget(context, status, controller),
        ),
      ],
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
        return const SliverToBoxAdapter(child: NoDataBox());
      }

      return SliverPostGrid(
        posts: posts,
        scrollController: controller,
        onTap: (post, index) {
          goToDetailPage(
            context: context,
            posts: posts,
            initialIndex: index,
            scrollController: controller,
            postBloc: context.read<PostBloc>(),
          );
        },
        onFavoriteUpdated: (postId, value) => context
            .read<PostBloc>()
            .add(PostFavoriteUpdated(postId: postId, favorite: value)),
      );
    } else if (status == LoadStatus.loading) {
      return posts.isEmpty
          ? const SliverPostGridPlaceHolder()
          : SliverPostGrid(
              posts: posts,
              scrollController: controller,
              onTap: (post, index) {
                goToDetailPage(
                  context: context,
                  posts: posts,
                  initialIndex: index,
                  scrollController: controller,
                  postBloc: context.read<PostBloc>(),
                );
              },
              onFavoriteUpdated: (postId, value) => context
                  .read<PostBloc>()
                  .add(PostFavoriteUpdated(postId: postId, favorite: value)),
            );
    } else {
      return const SliverToBoxAdapter(
        child: ErrorBox(),
      );
    }
  }
}
