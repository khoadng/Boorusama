// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

class HomePostGrid extends StatelessWidget {
  const HomePostGrid({
    Key? key,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  final AutoScrollController controller;
  final VoidCallback? onTap;

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
                return SliverPostGridPlaceHolder(gridSize: gridSize);
              } else if (state.status == LoadStatus.success) {
                if (state.posts.isEmpty) {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text('No data')));
                }
                return SliverPostGrid(
                  posts: state.posts,
                  scrollController: controller,
                  gridSize: gridSize,
                  borderRadius: _gridSizeToBorderRadius(gridSize),
                  onTap: (post, index) {
                    onTap?.call();
                    AppRouter.router.navigateTo(
                      context,
                      '/post/detail',
                      routeSettings: RouteSettings(
                        arguments: [
                          state.posts,
                          index,
                          controller,
                        ],
                      ),
                    );
                  },
                );
              } else if (state.status == LoadStatus.loading) {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text('Something went wrong'),
                  ),
                );
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
