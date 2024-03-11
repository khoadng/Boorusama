// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'gelbooru_desktop_home_page.dart';

class GelbooruHomePage extends ConsumerStatefulWidget {
  const GelbooruHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends ConsumerState<GelbooruHomePage> {
  @override
  Widget build(BuildContext context) {
    final favoritePageBuilder =
        ref.watchBooruBuilder(ref.watchConfig)?.favoritesPageBuilder;

    return BooruScope(
      config: widget.config,
      mobileView: (controller) => _GelbooruMobileHomeView(
        controller: controller,
      ),
      mobileMenuBuilder: (context, controller) => [
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
          SideMenuTile(
            icon: const Icon(
              Symbols.favorite,
              fill: 1,
            ),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.dashboard,
          icon: Symbols.dashboard,
          title: 'Home',
        ),
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ...coreDesktopTabBuilder(
          context,
          constraints,
          controller,
        ),
      ],
      desktopViews: () {
        final gelbooruTabs = [
          const GelbooruDesktopHomePage(),
          if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
            GelbooruFavoritesPage(uid: ref.watchConfig.login!),
        ];

        return [
          ...gelbooruTabs,
          ...coreDesktopViewBuilder(
            previousItemCount: gelbooruTabs.length,
          ),
        ];
      },
    );
  }
}

class _GelbooruMobileHomeView extends ConsumerWidget {
  const _GelbooruMobileHomeView({
    required this.controller,
  });

  final HomePageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.readConfig;

    return PostScope(
      // Need to use generic repo here because this is used not only for Gelbooru
      fetcher: (page) => ref.read(postRepoProvider(config)).getPosts([], page),
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
