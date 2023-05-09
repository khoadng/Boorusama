// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

class ExploreHotPage extends StatelessWidget {
  const ExploreHotPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreHot,
        ),
        builder: (_) => DanbooruProvider.of(
          context,
          builder: (dcontext) {
            return const CustomContextMenuOverlay(
              child: ExploreHotPage(),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DanbooruPostScope(
            fetcher: (page) =>
                context.read<ExploreRepository>().getHotPosts(page),
            builder: (context, controller, errors) => DanbooruInfinitePostList(
              errors: errors,
              controller: controller,
              sliverHeaderBuilder: (context) => [
                ExploreSliverAppBar(
                  title: 'explore.hot'.tr(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
