// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_handler/share_handler.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/home/home_navigation_tile.dart';
import '../../../../core/home/home_page_scaffold.dart';
import '../../../../core/home/side_menu_tile.dart';
import '../../../../core/posts/favorites/routes.dart';
import '../../../../core/theme.dart';
import '../../../../foundation/platform.dart';
import '../../../../foundation/url_launcher.dart';
import '../../artists/search/routes.dart';
import '../../artists/search/widgets.dart';
import '../../blacklist/routes.dart';
import '../../blacklist/widgets.dart';
import '../../forums/topics/routes.dart';
import '../../forums/topics/widgets.dart';
import '../../posts/explores/routes.dart';
import '../../posts/explores/widgets.dart';
import '../../posts/favgroups/listing/routes.dart';
import '../../posts/favgroups/listing/widgets.dart';
import '../../posts/favorites/widgets.dart';
import '../../posts/pools/listing/routes.dart';
import '../../posts/pools/listing/widgets.dart';
import '../../saved_searches/feed/routes.dart';
import '../../saved_searches/feed/widgets.dart';
import '../../tags/trending/providers.dart';
import '../../users/details/routes.dart';
import '../../users/details/widgets.dart';
import '../../users/user/providers.dart';

class DanbooruHomePage extends ConsumerStatefulWidget {
  const DanbooruHomePage({
    super.key,
  });

  @override
  ConsumerState<DanbooruHomePage> createState() => _DanbooruHomePageState();
}

class _DanbooruHomePageState extends ConsumerState<DanbooruHomePage> {
  StreamSubscription? _sharedMediaSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Only support Android for now
    if (!isAndroid()) return;

    _sharedMediaSubscription = ShareHandler.instance.sharedMediaStream.listen(
      _onSharedTextsReceived,
    );
  }

  void _onSharedTextsReceived(SharedMedia media) {
    final text = media.content;
    final config = ref.readConfigAuth;
    final booruUrl = config.url;

    if (config.hasStrictSFW) return;

    final uri = text != null ? Uri.tryParse(text) : null;
    final isHttp = uri?.scheme == 'http' || uri?.scheme == 'https';

    if (uri != null && isHttp) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          settings: const RouteSettings(name: 'upload_to_booru_confirmation'),
          builder: (context) {
            return AlertDialog(
              title: Text('Upload to Danbooru'.hc),
              content: Text(
                'Are you sure you want to upload to Danbooru?\n\n$text \n\nYou need to be logged in the browser to upload.'
                    .hc,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(context.t.generic.action.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    final encodedUri = Uri.encodeFull(uri.toString());
                    final url = '${booruUrl}uploads/new?url=$encodedUri';
                    launchExternalUrlString(url);
                  },
                  child: Text(context.t.generic.action.ok),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configFilter = ref.watchConfigFilter;
    final config = configFilter.auth;

    final userId = ref
        .watch(danbooruCurrentUserProvider(config))
        .maybeWhen(
          data: (user) => user?.id,
          orElse: () => null,
        );

    ref.listen(
      trendingTagsProvider(configFilter),
      (previous, next) {
        // Only used to prevent the provider from being disposed
      },
    );

    return HomePageScaffold(
      mobileMenu: [
        if (config.hasLoginDetails() && userId != null)
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
          title: Text('Pools'.hc),
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
          title: Text('Artists'.hc),
          onTap: () {
            goToArtistSearchPage(ref);
          },
        ),
        if (config.hasLoginDetails()) ...[
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
          title: 'Pools',
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
          title: 'Artists',
        ),
        if (config.hasLoginDetails()) ...[
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
            title: 'Favorites',
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
        if (config.hasLoginDetails()) ...[
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
