// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';

class GelbooruMobileHomePage extends ConsumerWidget {
  const GelbooruMobileHomePage({
    super.key,
    required this.controller,
  });

  final HomePageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return PostScope(
      // Need to use generic repo here because this is used not only for Gelbooru
      fetcher: (page) => ref.read(postRepoProvider(config)).getPosts('', page),
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
