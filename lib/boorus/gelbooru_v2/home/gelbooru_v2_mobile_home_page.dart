// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class GelbooruV2MobileHomePage extends ConsumerWidget {
  const GelbooruV2MobileHomePage({
    super.key,
    required this.controller,
  });

  final HomePageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.readConfig;

    return PostScope(
      fetcher: (page) =>
          ref.read(gelbooruV2PostRepoProvider(config)).getPosts([], page),
      builder: (context, postController, errors) => InfinitePostListScaffold(
        errors: errors,
        controller: postController,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            toolbarHeight: kToolbarHeight * 1.2,
            title: HomeSearchBar(
              onMenuTap: controller.openMenu,
              onTap: () => goToSearchPage(context),
            ),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
          const SliverAppAnnouncementBanner(),
        ],
      ),
    );
  }
}
