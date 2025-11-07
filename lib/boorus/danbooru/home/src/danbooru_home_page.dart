// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../core/configs/config/providers.dart';
import '../../../../core/home/widgets.dart';
import '../../../../core/posts/favorites/routes.dart';
import '../../../../core/themes/theme/types.dart';
import '../../artists/search/routes.dart';
import '../../artists/search/widgets.dart';
import '../../blacklist/routes.dart';
import '../../blacklist/widgets.dart';
import '../../favgroups/listing/routes.dart';
import '../../favgroups/listing/widgets.dart';
import '../../forums/topics/routes.dart';
import '../../forums/topics/widgets.dart';
import '../../pools/listing/routes.dart';
import '../../pools/listing/widgets.dart';
import '../../posts/explores/routes.dart';
import '../../posts/explores/widgets.dart';
import '../../posts/favorites/widgets.dart';
import '../../posts/uploads/widgets.dart';
import '../../saved_searches/feed/routes.dart';
import '../../saved_searches/feed/widgets.dart';
import '../../users/details/routes.dart';
import '../../users/details/widgets.dart';
import '../../users/user/providers.dart';

class DanbooruHomePage extends ConsumerWidget {
  const DanbooruHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const UploadToDanbooru(
      child: _DanbooruHomePageContent(),
    );
  }
}

class _DanbooruHomePageContent extends ConsumerWidget {
  const _DanbooruHomePageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configFilter = ref.watchConfigFilter;
    final config = configFilter.auth;
    final loginDetails = ref.watch(booruLoginDetailsProvider(config));

    final userId = ref
        .watch(danbooruCurrentUserProvider(config))
        .maybeWhen(
          data: (user) => user?.id,
          orElse: () => null,
        );

    return HomePageScaffold(
      mobileMenu: [
        if (loginDetails.hasLogin() && userId != null)
          SideMenuTile(
            icon: const _Icon(
              Symbols.account_box,
            ),
            title: Text(context.t.profile.profile),
            onTap: () {
              goToProfilePage(ref);
            },
          ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.explore,
          ),
          title: Text(context.t.explore.explore),
          onTap: () => goToExplorePage(ref),
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.photo_album,
          ),
          title: Text(context.t.pool.pools),
          onTap: () {
            goToPoolPage(ref);
          },
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.forum,
          ),
          title: Text(context.t.forum.forum),
          onTap: () {
            goToForumPage(ref);
          },
        ),
        SideMenuTile(
          icon: const _Icon(
            Symbols.search,
          ),
          title: Text(context.t.artists.title),
          onTap: () {
            goToArtistSearchPage(ref);
          },
        ),
        if (loginDetails.hasLogin()) ...[
          SideMenuTile(
            icon: const _Icon(
              Symbols.favorite,
            ),
            title: Text(context.t.profile.favorites),
            onTap: () {
              goToFavoritesPage(ref);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.collections,
            ),
            title: Text(context.t.favorite_groups.favorite_groups),
            onTap: () {
              goToFavoriteGroupPage(ref);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.search,
            ),
            title: Text(context.t.saved_search.saved_search),
            onTap: () {
              goToSavedSearchPage(ref);
            },
          ),
          SideMenuTile(
            icon: const _Icon(
              Symbols.tag,
            ),
            title: Text(
              context.t.blacklisted_tags.blacklisted_tags,
            ),
            onTap: () {
              goToBlacklistedTagPage(ref);
            },
          ),
        ],
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: context.t.explore.explore,
        ),
        HomeNavigationTile(
          value: 2,
          constraints: constraints,
          selectedIcon: Symbols.photo_album,
          icon: Symbols.photo_album,
          title: context.t.pool.pools,
        ),
        HomeNavigationTile(
          value: 3,
          constraints: constraints,
          selectedIcon: Symbols.forum,
          icon: Symbols.forum,
          title: context.t.forum.forum,
        ),
        HomeNavigationTile(
          value: 4,
          constraints: constraints,
          selectedIcon: Symbols.search,
          icon: Symbols.search,
          title: context.t.artists.title,
        ),
        if (loginDetails.hasLogin()) ...[
          if (userId != null)
            HomeNavigationTile(
              value: 5,
              constraints: constraints,
              selectedIcon: Symbols.account_box,
              icon: Symbols.account_box,
              title: context.t.profile.profile,
            ),
          HomeNavigationTile(
            value: 6,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: context.t.profile.favorites,
          ),
          HomeNavigationTile(
            value: 7,
            constraints: constraints,
            selectedIcon: Symbols.collections,
            icon: Symbols.collections,
            title: context.t.favorite_groups.favorite_groups,
          ),
          HomeNavigationTile(
            value: 8,
            constraints: constraints,
            selectedIcon: Symbols.saved_search,
            icon: Symbols.saved_search,
            title: context.t.saved_search.saved_search,
          ),
          HomeNavigationTile(
            value: 9,
            constraints: constraints,
            selectedIcon: Symbols.tag,
            icon: Symbols.tag,
            title: context.t.blacklisted_tags.blacklisted_tags,
          ),
        ],
      ],
      desktopViews: [
        // 1
        const DanbooruExplorePageDesktop(),
        // 2
        const DanbooruPoolPage(),
        // 3
        const DanbooruForumPage(),
        // 4
        const DanbooruArtistSearchPage(),
        if (loginDetails.hasLogin()) ...[
          if (userId != null)
            // 5
            const DanbooruProfilePage(
              hasAppBar: false,
            ),
          // 6
          const DanbooruFavoritesPage(),
          // 7
          const FavoriteGroupsPage(),
          // 8
          const SavedSearchFeedPage(),
          // 9
          const DanbooruBlacklistedTagsPage(),
        ],
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon(
    this.icon,
  );

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      fill: Theme.of(context).brightness.isLight ? 0 : 1,
    );
  }
}
