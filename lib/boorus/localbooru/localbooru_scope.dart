// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/home/simple_home_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/boorus/core/widgets/home_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/posts/post_scope.dart';
import 'package:boorusama/boorus/home_page.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'locabooru_provider.dart';

class LocalbooruScope extends ConsumerStatefulWidget {
  const LocalbooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<LocalbooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends ConsumerState<LocalbooruScope> {
  @override
  Widget build(BuildContext context) {
    return LocalbooruProvider(
      builder: (context) => BooruScope(
        config: widget.config,
        mobileView: (controller) => _SimpleMobileHomeView(
          controller: controller,
        ),
        mobileMenuBuilder: (context, controller) => [],
        desktopMenuBuilder: (context, controller, constraints) => [
          HomeNavigationTile(
            value: 0,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.dashboard),
            icon: const Icon(Icons.dashboard_outlined),
            title: 'Home',
          ),
          // const Divider(),
          // HomeNavigationTile(
          //   value: 1,
          //   controller: controller,
          //   constraints: constraints,
          //   selectedIcon: const Icon(Icons.bookmark),
          //   icon: const Icon(Icons.bookmark_border_outlined),
          //   title: 'sideMenu.your_bookmarks'.tr(),
          // ),
          // HomeNavigationTile(
          //   value: 2,
          //   controller: controller,
          //   constraints: constraints,
          //   selectedIcon: const Icon(Icons.list_alt),
          //   icon: const Icon(Icons.list_alt_outlined),
          //   title: 'sideMenu.your_blacklist'.tr(),
          // ),
          // HomeNavigationTile(
          //   value: 3,
          //   controller: controller,
          //   constraints: constraints,
          //   selectedIcon: const Icon(Icons.download),
          //   icon: const Icon(Icons.download_outlined),
          //   title: 'sideMenu.bulk_download'.tr(),
          // ),
          const Divider(),
          HomeNavigationTile(
            value: 999,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.settings),
            icon: const Icon(Icons.settings),
            title: 'sideMenu.settings'.tr(),
            onTap: () => context.go('/settings'),
          ),
        ],
        desktopViews: const [
          SimpleHomePage(),
          // BookmarkPage(),
          // BlacklistedTagPage(),
        ],
      ),
    );
  }
}

class _SimpleMobileHomeView extends ConsumerWidget {
  const _SimpleMobileHomeView({
    required this.controller,
  });

  final HomePageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostScope(
      fetcher: (page) => ref.read(postRepoProvider).getPostsFromTags('', page),
      builder: (context, postController, errors) => CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            toolbarHeight: kToolbarHeight * 1.2,
            title: HomeSearchBar(
              onMenuTap: controller.openMenu,
              onTap: () => print('search'),
            ),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) =>
                Image.file(File(postController.items[index].thumbnailImageUrl)),
          ),
        ],
      ),
    );
  }
}
