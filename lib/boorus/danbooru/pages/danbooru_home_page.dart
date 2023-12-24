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
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import '../feats/dmails/dmails.dart';
import '../feats/users/users.dart';
import 'blacklisted_tags_page.dart';
import 'danbooru_artist_search_page.dart';
import 'danbooru_desktop_home_page.dart';
import 'danbooru_dmail_page.dart';
import 'danbooru_forum_page.dart';
import 'explore_page.dart';
import 'favorite_groups_page.dart';
import 'favorites_page.dart';
import 'latest_posts_view.dart';
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

    return BooruScope(
      config: widget.config,
      mobileView: (controller) => LatestView(
        searchBar: HomeSearchBar(
          onMenuTap: controller.openMenu,
          onTap: () => goToSearchPage(context),
        ),
      ),
      mobileMenuBuilder: (context, controller) => [
        if (widget.config.hasLoginDetails() && userId != null)
          SideMenuTile(
            icon: const Icon(Symbols.account_box),
            title: const Text('Profile'),
            onTap: () {
              goToUserDetailsPage(
                ref,
                context,
                uid: userId,
                username: widget.config.login!,
              );
            },
          ),
        SideMenuTile(
          icon: const Icon(Symbols.explore),
          title: const Text('Explore'),
          onTap: () => context.navigator.push(CupertinoPageRoute(
              builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Explore'),
                    ),
                    body: const ExplorePage(),
                  ))),
        ),
        SideMenuTile(
          icon: const Icon(Symbols.photo_album),
          title: const Text('Pools'),
          onTap: () {
            goToPoolPage(context, ref);
          },
        ),
        SideMenuTile(
          icon: const Icon(Symbols.forum),
          title: const Text('forum.forum').tr(),
          onTap: () {
            goToForumPage(context);
          },
        ),
        SideMenuTile(
          icon: const Icon(Symbols.search),
          title: const Text('Artists'),
          onTap: () {
            goToArtistSearchPage(context);
          },
        ),
        if (widget.config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
          SideMenuTile(
            icon: const Icon(Symbols.collections),
            title: const Text('favorite_groups.favorite_groups').tr(),
            onTap: () {
              goToFavoriteGroupPage(context);
            },
          ),
          SideMenuTile(
            icon: const Icon(Symbols.search),
            title: const Text('saved_search.saved_search').tr(),
            onTap: () {
              goToSavedSearchPage(context, widget.config.login);
            },
          ),
          SideMenuTile(
            icon: const Icon(Symbols.tag),
            title: const Text(
              'blacklisted_tags.blacklisted_tags',
            ).tr(),
            onTap: () {
              goToBlacklistedTagPage(context);
            },
          ),
          SideMenuTile(
            icon: ref
                .watch(danbooruUnreadDmailsProvider(widget.config))
                .maybeWhen(
                  data: (data) => data.isNotEmpty
                      ? Badge.count(
                          count: data.length,
                          child: const Icon(Symbols.mail),
                        )
                      : const Icon(Symbols.mail),
                  orElse: () => const Icon(Symbols.mail),
                ),
            title: const Text(
              'Dmails',
            ),
            onTap: () {
              goToDmailPage(context);
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
          title: 'Explore',
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
              title: 'Profile',
            )
          else
            const SizedBox(),
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
          HomeNavigationTile(
            value: 10,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.mail,
            icon: Symbols.mail,
            title: 'Dmails',
          ),
        ],
        const Divider(),
        HomeNavigationTile(
          value: 11,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.bookmark,
          icon: Symbols.bookmark,
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 12,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.list_alt,
          icon: Symbols.list_alt,
          title: 'sideMenu.your_blacklist'.tr(),
        ),
        HomeNavigationTile(
          value: 13,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.download,
          icon: Symbols.download,
          title: 'sideMenu.bulk_download'.tr(),
        ),
        const Divider(),
        HomeNavigationTile(
          value: 999,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.settings,
          icon: Symbols.settings,
          title: 'sideMenu.settings'.tr(),
          onTap: () => context.go('/settings'),
        ),
      ],
      desktopViews: [
        const DanbooruDesktopHomePage(),
        const ExplorePageDesktop(),
        const PoolPage(),
        const DanbooruForumPage(),
        const DanbooruArtistSearchPage(),
        if (widget.config.hasLoginDetails()) ...[
          if (userId != null)
            UserDetailsPage(
              uid: userId,
              username: widget.config.login!,
              hasAppBar: false,
            )
          else
            const SizedBox(),
          DanbooruFavoritesPage(username: widget.config.login!),
          const FavoriteGroupsPage(),
          const SavedSearchFeedPage(),
          const BlacklistedTagsPage(),
          const DanbooruDmailPage(),
        ] else ...[
          //TODO: hacky way to prevent accessing wrong index... Will need better solution
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
        const BookmarkPage(),
        const BlacklistedTagPage(),
        const BulkDownloadPage(),
      ],
    );
  }
}
