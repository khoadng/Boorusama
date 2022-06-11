// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class SliverPostImageGrid extends StatelessWidget {
  const SliverPostImageGrid({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AutoScrollController controller;

  Widget mapStateToWidget(BuildContext context, PostState state) {
    if (state.status == PostStatus.initial) {
      return const SliverPostGridPlaceHolder();
    } else if (state.status == PostStatus.success) {
      return SliverPostGrid(
        posts: state.posts,
        scrollController: controller,
        onTap: (post, index) => AppRouter.router.navigateTo(
          context,
          "/post/detail",
          routeSettings: RouteSettings(
            arguments: [
              state.posts,
              index,
              controller,
            ],
          ),
        ),
      );
    } else if (state.status == PostStatus.loading) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    } else {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text("Something went wrong"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      sliver: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => current.status != PostStatus.loading,
        builder: mapStateToWidget,
      ),
    );
  }
}
