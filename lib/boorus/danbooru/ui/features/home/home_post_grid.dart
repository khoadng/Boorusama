// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';

class HomePostGrid extends StatelessWidget {
  const HomePostGrid({
    Key? key,
    required this.controller,
    this.onTap,
    this.usePlaceholder = true,
    this.onRefresh,
  }) : super(key: key);

  final AutoScrollController controller;
  final VoidCallback? onTap;
  final bool usePlaceholder;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      sliver: BlocSelector<SettingsCubit, SettingsState, GridSize>(
        selector: (state) => state.settings.gridSize,
        builder: (context, gridSize) {
          return BlocBuilder<PostBloc, PostState>(
            buildWhen: (previous, current) =>
                current.status != LoadStatus.loading,
            builder: (context, state) {
              if (state.status == LoadStatus.initial) {
                return usePlaceholder
                    ? SliverPostGridPlaceHolder(gridSize: gridSize)
                    : const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
              } else if (state.status == LoadStatus.success) {
                if (state.posts.isEmpty) {
                  return const SliverToBoxAdapter(child: NoDataBox());
                }
                return SliverPostGrid(
                  posts: state.posts,
                  scrollController: controller,
                  gridSize: gridSize,
                  borderRadius: _gridSizeToBorderRadius(gridSize),
                  onTap: (post, index) {
                    onTap?.call();
                    goToDetailPage(
                      context: context,
                      posts: state.posts,
                      initialIndex: index,
                      scrollController: controller,
                      postBloc: context.read<PostBloc>(),
                    );
                  },
                  onFavoriteUpdated: (postId, value) => context
                      .read<PostBloc>()
                      .add(
                          PostFavoriteUpdated(postId: postId, favorite: value)),
                );
              } else if (state.status == LoadStatus.loading) {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              } else {
                return const SliverToBoxAdapter(child: ErrorBox());
              }
            },
          );
        },
      ),
    );
  }
}

BorderRadius _gridSizeToBorderRadius(GridSize size) {
  switch (size) {
    case GridSize.small:
      return BorderRadius.circular(3);
    // case GridSize.large:
    //   return const BorderRadius.only(
    //     topLeft: Radius.circular(8),
    //     topRight: Radius.circular(8),
    //   );

    default:
      return BorderRadius.circular(8);
  }
}
