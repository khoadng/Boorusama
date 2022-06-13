// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => !current.hasMore,
        builder: (context, state) {
          return InfiniteLoadList(
            enableLoadMore: state.hasMore,
            onLoadMore: () => context
                .read<PostBloc>()
                .add(PostFetched(tags: 'ordfav:$username')),
            onRefresh: (controller) {
              context
                  .read<PostBloc>()
                  .add(PostRefreshed(tag: 'ordfav:$username'));
              Future.delayed(const Duration(milliseconds: 500),
                  () => controller.refreshCompleted());
            },
            builder: (context, controller) => CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: BlocBuilder<PostBloc, PostState>(
                    buildWhen: (previous, current) =>
                        current.status != LoadStatus.loading,
                    builder: (context, state) {
                      if (state.status == LoadStatus.initial) {
                        return const SliverPostGridPlaceHolder();
                      } else if (state.status == LoadStatus.success) {
                        if (state.posts.isEmpty) {
                          return const SliverToBoxAdapter(
                              child: Center(child: Text('No data')));
                        }
                        return SliverPostGrid(
                          posts: state.posts,
                          scrollController: controller,
                          onTap: (post, index) => AppRouter.router.navigateTo(
                            context,
                            '/post/detail',
                            routeSettings: RouteSettings(
                              arguments: [
                                state.posts,
                                index,
                                controller,
                              ],
                            ),
                          ),
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
                  ),
                ),
                if (state.status == LoadStatus.loading && state.hasMore)
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
