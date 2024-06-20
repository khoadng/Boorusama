// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_handler/share_handler.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import '../feats/users/users.dart';
import 'blacklisted_tags_page.dart';
import 'danbooru_artist_search_page.dart';
import 'danbooru_desktop_home_page.dart';
import 'danbooru_forum_page.dart';
import 'explore_page.dart';
import 'favorite_groups_page.dart';
import 'favorites_page.dart';
import 'pool_page.dart';
import 'saved_search_feed_page.dart';
import 'user_details_page.dart';

class DanbooruHomePage extends ConsumerStatefulWidget {
  const DanbooruHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

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

    _sharedMediaSubscription =
        ShareHandler.instance.sharedMediaStream.listen(_onSharedTextsReceived);
  }

  void _onSharedTextsReceived(SharedMedia media) {
    final text = media.content;
    final config = ref.readConfig;
    final booruName = config.booruType.stringify();
    final booruUrl = config.url;

    if (config.hasStrictSFW) return;

    if (text != null) {
      context.navigator.push(CupertinoPageRoute(
        builder: (context) {
          return AlertDialog(
            title: Text('Upload to $booruName'),
            content: Text(
                'Are you sure you want to upload to $booruName?\n\n$text \n\nYou need to be logged in the browser to upload.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final uri = Uri.tryParse(text);

                  if (uri != null) {
                    final encodedUri = Uri.encodeFull(text);
                    final url = '${booruUrl}uploads/new?url=$encodedUri';
                    launchExternalUrlString(url);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ));
    }
  }

  @override
  void dispose() {
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        ref.watch(danbooruCurrentUserProvider(widget.config)).maybeWhen(
              data: (user) => user?.id,
              orElse: () => null,
            );

    ref.listen(
      trendingTagsProvider(ref.watchConfig),
      (previous, next) {
        // Only used to prevent the provider from being disposed
      },
    );

    return BooruScope(
      config: widget.config,
      mobileMenuBuilder: (context, controller) => [
        if (widget.config.hasLoginDetails() && userId != null)
          SideMenuTile(
            icon: Icon(
              Symbols.account_box,
              fill: context.themeMode.isLight ? 0 : 1,
            ),
            title: const Text('profile.profile').tr(),
            onTap: () {
              goToUserDetailsPage(
                ref,
                context,
                uid: userId,
                username: widget.config.login!,
                isSelf: true,
              );
            },
          ),
        SideMenuTile(
          icon: Icon(
            Symbols.explore,
            fill: context.themeMode.isLight ? 0 : 1,
          ),
          title: const Text('explore.explore').tr(),
          onTap: () => context.navigator.push(CupertinoPageRoute(
              builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('explore.explore').tr(),
                    ),
                    body: const ExplorePage(),
                  ))),
        ),
        SideMenuTile(
          icon: Icon(
            Symbols.photo_album,
            fill: context.themeMode.isLight ? 0 : 1,
          ),
          title: const Text('Pools'),
          onTap: () {
            goToPoolPage(context, ref);
          },
        ),
        SideMenuTile(
          icon: Icon(
            Symbols.forum,
            fill: context.themeMode.isLight ? 0 : 1,
          ),
          title: const Text('forum.forum').tr(),
          onTap: () {
            goToForumPage(context);
          },
        ),
        SideMenuTile(
          icon: const Icon(
            Symbols.search,
            fill: 1,
          ),
          title: const Text('Artists'),
          onTap: () {
            goToArtistSearchPage(context);
          },
        ),
        if (widget.config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: Icon(
              Symbols.favorite,
              fill: context.themeMode.isLight ? 0 : 1,
            ),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
          SideMenuTile(
            icon: Icon(
              Symbols.collections,
              fill: context.themeMode.isLight ? 0 : 1,
            ),
            title: const Text('favorite_groups.favorite_groups').tr(),
            onTap: () {
              goToFavoriteGroupPage(context);
            },
          ),
          SideMenuTile(
            icon: const Icon(
              Symbols.search,
              fill: 1,
            ),
            title: const Text('saved_search.saved_search').tr(),
            onTap: () {
              goToSavedSearchPage(context, widget.config.login);
            },
          ),
          SideMenuTile(
            icon: const Icon(
              Symbols.tag,
              fill: 1,
            ),
            title: const Text(
              'blacklisted_tags.blacklisted_tags',
            ).tr(),
            onTap: () {
              goToBlacklistedTagPage(context);
            },
          ),
        ]
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
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'explore.explore'.tr(),
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.photo_album,
          icon: Symbols.photo_album,
          title: 'Pools',
        ),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.forum,
          icon: Symbols.forum,
          title: 'forum.forum'.tr(),
        ),
        HomeNavigationTile(
          value: 4,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.search,
          icon: Symbols.search,
          title: 'Artists',
        ),
        if (widget.config.hasLoginDetails()) ...[
          if (userId != null)
            HomeNavigationTile(
              value: 5,
              controller: controller,
              constraints: constraints,
              selectedIcon: Symbols.account_box,
              icon: Symbols.account_box,
              title: 'profile.profile'.tr(),
            ),
          HomeNavigationTile(
            value: 6,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
          HomeNavigationTile(
            value: 7,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.collections,
            icon: Symbols.collections,
            title: 'favorite_groups.favorite_groups'.tr(),
          ),
          HomeNavigationTile(
            value: 8,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.saved_search,
            icon: Symbols.saved_search,
            title: 'saved_search.saved_search'.tr(),
          ),
          HomeNavigationTile(
            value: 9,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.tag,
            icon: Symbols.tag,
            title: 'blacklisted_tags.blacklisted_tags'.tr(),
          ),
        ],
        ...coreDesktopTabBuilder(
          context,
          constraints,
          controller,
        ),
      ],
      desktopViews: () {
        final danbooruTabs = [
          // 0
          const DanbooruDesktopHomePage(),
          // 1
          const ExplorePageDesktop(),
          // 2
          const PoolPage(),
          // 3
          const DanbooruForumPage(),
          // 4
          const DanbooruArtistSearchPage(),
          if (widget.config.hasLoginDetails()) ...[
            if (userId != null)
              // 5
              UserDetailsPage(
                uid: userId,
                username: widget.config.login!,
                hasAppBar: false,
              ),
            // 6
            DanbooruFavoritesPage(username: widget.config.login!),
            // 7
            const FavoriteGroupsPage(),
            // 8
            const SavedSearchFeedPage(),
            // 9
            const BlacklistedTagsPage(),
          ],
        ];

        return [
          ...danbooruTabs,
          ...coreDesktopViewBuilder(
            previousItemCount: danbooruTabs.length,
          ),
        ];
      },
    );
  }
}
