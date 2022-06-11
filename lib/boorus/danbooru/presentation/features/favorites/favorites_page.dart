// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/bottom_loading_indicator.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_image_grid.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InfiniteLoadList2(
        extendBody: true,
        onLoadMore: () =>
            context.read<PostBloc>().add(PostFetched(tags: "ordfav:$username")),
        onRefresh: (controller) {
          context.read<PostBloc>().add(PostRefreshed(tag: "ordfav:$username"));
          Future.delayed(
              const Duration(seconds: 1), () => controller.refreshCompleted());
        },
        builder: (context, controller) => CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverPostImageGrid(controller: controller),
            const BottomLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
