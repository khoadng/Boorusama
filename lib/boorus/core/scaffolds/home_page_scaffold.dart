// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'desktop_home_page_scaffold.dart';
import 'mobile_home_page_scaffold.dart';
import 'post_details_page_scaffold.dart';

class HomePageScaffold extends ConsumerStatefulWidget {
  const HomePageScaffold({
    super.key,
    this.onPostTap,
    this.onSearchTap,
  });

  final void Function(
    BuildContext context,
    List<Post> posts,
    Post post,
    AutoScrollController scrollController,
    Settings settings,
    int initialIndex,
  )? onPostTap;
  final void Function()? onSearchTap;

  @override
  ConsumerState<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends ConsumerState<HomePageScaffold> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(currentBooruConfigProvider);
    final booruBuilders = ref.watch(booruBuildersProvider);
    final fetcher = booruBuilders[config.booruType]?.postFetcher;

    return BooruScope(
      config: config,
      mobileView: (controller) => MobileHomePageScaffold(
        controller: controller,
        onPostTap: widget.onPostTap ??
            (context, posts, post, scrollController, settings, initialIndex) =>
                _goToPostDetailsPage(
                  context: context,
                  posts: posts,
                  initialIndex: initialIndex,
                  scrollController: scrollController,
                  fetcher: (page, tags) =>
                      fetcher?.call(page, tags) ?? TaskEither.of(<Post>[]),
                ),
        onSearchTap: widget.onSearchTap ??
            () => _goToSearchPage(
                  context,
                  fetcher: (page, tags) =>
                      fetcher?.call(page, tags) ?? TaskEither.of(<Post>[]),
                ),
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
        const Divider(),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.bookmark),
          icon: const Icon(Icons.bookmark_border_outlined),
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.list_alt),
          icon: const Icon(Icons.list_alt_outlined),
          title: 'sideMenu.your_blacklist'.tr(),
        ),
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
      desktopViews: [
        DesktopHomePageScaffold(
          onPostTap: widget.onPostTap ??
              (context, posts, post, scrollController, settings,
                      initialIndex) =>
                  _goToPostDetailsPage(
                    context: context,
                    posts: posts,
                    initialIndex: initialIndex,
                    scrollController: scrollController,
                    fetcher: (page, tags) =>
                        fetcher?.call(page, tags) ?? TaskEither.of(<Post>[]),
                  ),
        ),
        const BookmarkPage(),
        const BlacklistedTagPage(),
      ],
    );
  }
}

void _goToSearchPage<T extends Post>(
  BuildContext context, {
  required PostsOrErrorCore<T> Function(int page, String tags) fetcher,
  String? tag,
}) {
  context.navigator.push(PageTransition(
    type: PageTransitionType.fade,
    child: SearchPageScaffold<T>(
        initialQuery: tag,
        fetcher: fetcher,
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                _goToPostDetailsPage<T>(
                  context: context,
                  posts: posts,
                  initialIndex: initialIndex,
                  scrollController: scrollController,
                  fetcher: fetcher,
                )),
  ));
}

void _goToPostDetailsPage<T extends Post>({
  required BuildContext context,
  required List<T> posts,
  required int initialIndex,
  required PostsOrErrorCore<T> Function(int page, String tags) fetcher,
  AutoScrollController? scrollController,
}) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => PostDetailsPageScaffold(
      posts: posts,
      initialIndex: initialIndex,
      onExit: (page) => scrollController?.scrollToIndex(page),
      onTagTap: (tag) => _goToSearchPage(
        context,
        tag: tag,
        fetcher: fetcher,
      ),
    ),
  ));
}
