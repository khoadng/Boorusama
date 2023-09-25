// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/explores/explore_sliver_app_bar.dart';

class ExploreHotPage extends ConsumerWidget {
  const ExploreHotPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreHot,
        ),
        builder: (_) => const CustomContextMenuOverlay(
          child: ExploreHotPage(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: DanbooruPostScope(
            fetcher: (page) =>
                ref.watch(danbooruExploreRepoProvider).getHotPosts(page),
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
