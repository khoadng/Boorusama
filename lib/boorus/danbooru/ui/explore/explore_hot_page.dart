// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/ui/posts/danbooru_infinite_post_list2.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'explore_mixins.dart';

class ExploreHotPage extends StatefulWidget {
  const ExploreHotPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreHot,
        ),
        builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dcontext) {
                return const CustomContextMenuOverlay(
                  child: ExploreHotPage(),
                );
              },
            );
          },
        ),
      );

  @override
  State<ExploreHotPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreHotPage>
    with DanbooruPostTransformMixin, PostExplorerServiceProviderMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (page) =>
        context.read<ExploreRepository>().getHotPosts(page).then(transform),
    refresher: () =>
        context.read<ExploreRepository>().getHotPosts(1).then(transform),
  );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DanbooruInfinitePostList2(
            controller: _controller,
            sliverHeaderBuilder: (context) => [
              ExploreSliverAppBar(
                title: 'explore.hot'.tr(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
