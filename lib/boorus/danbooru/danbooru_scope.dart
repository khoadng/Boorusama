// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/boorus/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/boorus/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/current_booru_tile.dart';
import 'package:boorusama/boorus/core/widgets/result_header.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/pages/forums/danbooru_forum_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/pages/search/result/related_tag_section.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import 'package:boorusama/widgets/lazy_indexed_stack.dart';
import 'package:boorusama/widgets/navigation_tile.dart';

class DanbooruScope extends ConsumerStatefulWidget {
  const DanbooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<DanbooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends ConsumerState<DanbooruScope> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final controller = HomePageController(scaffoldKey: scaffoldKey);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DanbooruProvider(
      builder: (context) => CustomContextMenuOverlay(
        child: isMobilePlatform()
            ? OrientationBuilder(
                builder: (context, orientation) => orientation.isPortrait
                    ? _MobileScope(
                        controller: controller,
                        config: widget.config,
                      )
                    : _DesktopScope(
                        controller: controller,
                        config: widget.config,
                      ),
              )
            : _DesktopScope(
                controller: controller,
                config: widget.config,
              ),
      ),
    );
  }
}

class _DesktopScope extends ConsumerStatefulWidget {
  const _DesktopScope({
    required this.controller,
    required this.config,
  });

  final HomePageController controller;
  final BooruConfig config;

  @override
  ConsumerState<_DesktopScope> createState() => _DesktopScopeState();
}

class _DesktopScopeState extends ConsumerState<_DesktopScope> {
  var booruMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authenticationProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Column(
              children: [
                const CurrentBooruTile(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Theme(
                          data: context.theme.copyWith(
                            iconTheme:
                                context.theme.iconTheme.copyWith(size: 20),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                HomeNavigationTile(
                                  value: 0,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.dashboard),
                                  icon: const Icon(Icons.dashboard_outlined),
                                  title: 'Home',
                                ),
                                HomeNavigationTile(
                                  value: 1,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.explore),
                                  icon: const Icon(Icons.explore_outlined),
                                  title: 'Explore',
                                ),
                                HomeNavigationTile(
                                  value: 2,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.photo_album),
                                  icon: const Icon(Icons.photo_album_outlined),
                                  title: 'Pools',
                                ),
                                HomeNavigationTile(
                                  value: 3,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.forum),
                                  icon: const Icon(Icons.forum_outlined),
                                  title: 'forum.forum'.tr(),
                                ),
                                if (auth.isAuthenticated) ...[
                                  HomeNavigationTile(
                                    value: 4,
                                    controller: widget.controller,
                                    constraints: constraints,
                                    selectedIcon: const Icon(Icons.favorite),
                                    icon: const Icon(
                                        Icons.favorite_border_outlined),
                                    title: 'Favorites',
                                  ),
                                  HomeNavigationTile(
                                    value: 5,
                                    controller: widget.controller,
                                    constraints: constraints,
                                    selectedIcon: const Icon(Icons.collections),
                                    icon:
                                        const Icon(Icons.collections_outlined),
                                    title:
                                        'favorite_groups.favorite_groups'.tr(),
                                  ),
                                  HomeNavigationTile(
                                    value: 6,
                                    controller: widget.controller,
                                    constraints: constraints,
                                    selectedIcon:
                                        const Icon(Icons.saved_search),
                                    icon:
                                        const Icon(Icons.saved_search_outlined),
                                    title: 'saved_search.saved_search'.tr(),
                                  ),
                                  HomeNavigationTile(
                                    value: 7,
                                    controller: widget.controller,
                                    constraints: constraints,
                                    selectedIcon: const Icon(Icons.tag),
                                    icon: const Icon(Icons.tag_outlined),
                                    title: 'blacklisted_tags.blacklisted_tags'
                                        .tr(),
                                  ),
                                ],
                                const Divider(),
                                HomeNavigationTile(
                                  value: 8,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.bookmark),
                                  icon: const Icon(
                                      Icons.bookmark_border_outlined),
                                  title: 'sideMenu.your_bookmarks'.tr(),
                                ),
                                HomeNavigationTile(
                                  value: 9,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.list_alt),
                                  icon: const Icon(Icons.list_alt_outlined),
                                  title: 'sideMenu.your_blacklist'.tr(),
                                ),
                                HomeNavigationTile(
                                  value: 10,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.download),
                                  icon: const Icon(Icons.download_outlined),
                                  title: 'sideMenu.bulk_download'.tr(),
                                ),
                                const Divider(),
                                HomeNavigationTile(
                                  value: 999,
                                  controller: widget.controller,
                                  constraints: constraints,
                                  selectedIcon: const Icon(Icons.settings),
                                  icon: const Icon(Icons.settings),
                                  title: 'sideMenu.settings'.tr(),
                                  onTap: () => context.go('/settings'),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, value, child) => LazyIndexedStack(
                index: value,
                children: [
                  const DanbooruHome2(),
                  const ExplorePage(),
                  const PoolPage(),
                  const DanbooruForumPage(),
                  if (auth.isAuthenticated) ...[
                    FavoritesPage(username: widget.config.login!),
                    const FavoriteGroupsPage(),
                    const SavedSearchFeedPage(),
                    const BlacklistedTagsPage(),
                  ] else ...[
                    //TODO: hacky way to prevent accessing wrong index... Will need better solution
                    const SizedBox(),
                    const SizedBox(),
                    const SizedBox(),
                    const SizedBox(),
                  ],
                  const BookmarkPage(),
                  const BlacklistedTagPage(),
                  const BulkDownloadPage(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DanbooruHome2 extends ConsumerStatefulWidget {
  const DanbooruHome2({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DanbooruHome2State();
}

class _DanbooruHome2State extends ConsumerState<DanbooruHome2> {
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  final textEditingController = TextEditingController();
  final showSuggestions = ValueNotifier(false);
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ref.read(searchHistoryProvider.notifier).fetchHistories();
    ref.read(postCountStateProvider.notifier).getPostCount([]);
    ref.read(danbooruRelatedTagsProvider.notifier).fetch('');
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    selectedTagController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    showSuggestions.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    return DanbooruPostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider).getPosts(
            selectedTagController.rawTagsString,
            page,
          ),
      builder: (context, controller, errors) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder(
            valueListenable: showSuggestions,
            builder: (context, show, child) {
              return Column(
                children: [
                  PortalTarget(
                    visible: show,
                    anchor: const Aligned(
                      follower: Alignment.topCenter,
                      target: Alignment.bottomCenter,
                      offset: Offset(-32, 0),
                    ),
                    portalFollower: SizedBox(
                      width: min(600, MediaQuery.of(context).size.width),
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: ValueListenableBuilder(
                        valueListenable: textEditingController,
                        builder: (context, query, child) {
                          final suggestionTags =
                              ref.watch(suggestionProvider(query.text));

                          return query.text.isNotEmpty
                              ? TagSuggestionItems(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  tags: suggestionTags,
                                  currentQuery: query.text,
                                  onItemTap: (tag) {
                                    selectedTagController.addTag(tag.value);
                                    textEditingController.clear();
                                    showSuggestions.value = false;
                                  },
                                  textColorBuilder: (tag) =>
                                      generateAutocompleteTagColor(
                                          tag, context.themeMode),
                                )
                              : Material(
                                  color: context.colorScheme.background,
                                  elevation: 4,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  child: SearchLandingView(
                                    onHistoryCleared: () => ref
                                        .read(searchHistoryProvider.notifier)
                                        .clearHistories(),
                                    onHistoryRemoved: (value) => ref
                                        .read(searchHistoryProvider.notifier)
                                        .removeHistory(value.query),
                                    onTagTap: (value) =>
                                        selectedTagController.addTag(
                                      value,
                                      operator: getFilterOperator(
                                          textEditingController.text),
                                    ),
                                    onHistoryTap: (value) =>
                                        selectedTagController.addTag(value),
                                    metatagsBuilder: (context) =>
                                        DanbooruMetatagsSection(
                                      onOptionTap: (value) {
                                        textEditingController.text = '$value:';
                                        _onTextChanged(
                                            textEditingController, '$value:');
                                      },
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                    child: SearchAppBar(
                      autofocus: false,
                      focusNode: focusNode,
                      queryEditingController: textEditingController,
                      onChanged: (value) => ref
                          .read(suggestionsProvider.notifier)
                          .getSuggestions(value),
                      onSubmitted: (value) {
                        selectedTagController.addTag(value);
                        textEditingController.clear();
                        showSuggestions.value = false;

                        _onSearch(controller);
                      },
                      onBack: null,
                      trailingSearchButton: MaterialButton(
                        minWidth: 0,
                        color: Theme.of(context).cardColor,
                        shape: const CircleBorder(),
                        onPressed: () => _onSearch(controller),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  SelectedTagListWithData(
                    controller: selectedTagController,
                  ),
                ],
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: selectedTagString,
            builder: (context, value, _) => Material(
              color: context.theme.scaffoldBackgroundColor,
              child: RelatedTagSection(
                backgroundColor: Colors.transparent,
                query: value,
                onSelected: (tag) => selectedTagController.addTag(tag.tag),
              ),
            ),
          ),
          Expanded(
            child: DanbooruInfinitePostList(
              controller: controller,
              errors: errors,
              sliverHeaderBuilder: (context) => [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: selectedTagString,
                        builder: (context, value, _) =>
                            ResultHeaderWithProvider(
                          selectedTags: value.split(' '),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  var selectedTagString = ValueNotifier('');

  void _onSearch(
    PostGridController postController,
  ) {
    ref
        .read(danbooruRelatedTagsProvider.notifier)
        .fetch(selectedTagController.rawTagsString);
    ref
        .read(postCountStateProvider.notifier)
        .getPostCount(selectedTagController.rawTags);
    selectedTagString.value = selectedTagController.rawTagsString;
    postController.refresh();
  }
}

void _onTextChanged(
  TextEditingController controller,
  String text,
) {
  controller
    ..text = text
    ..selection = TextSelection.collapsed(offset: controller.text.length);
}

class _MobileScope extends ConsumerWidget {
  const _MobileScope({
    required this.controller,
    required this.config,
  });

  final HomePageController controller;
  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final authState = ref.watch(authenticationProvider);
    // Only used to force rebuild when language changes
    ref.watch(settingsProvider.select((value) => value.language));

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            context.themeMode.isLight ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: controller.scaffoldKey,
        drawer: SideBarMenu(
          width: 300,
          popOnSelect: true,
          padding: EdgeInsets.zero,
          initialContentBuilder: (context) => [
            SideMenuTile(
              icon: const Icon(Icons.explore),
              title: const Text('Explore'),
              onTap: () => context.navigator.push(MaterialPageRoute(
                  builder: (_) => Scaffold(
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        body: const ExplorePage(),
                      ))),
            ),
            SideMenuTile(
              icon: const Icon(Icons.photo_album_outlined),
              title: const Text('Pools'),
              onTap: () {
                goToPoolPage(context, ref);
              },
            ),
            SideMenuTile(
              icon: const Icon(Icons.forum_outlined),
              title: const Text('forum.forum').tr(),
              onTap: () {
                goToForumPage(context);
              },
            ),
            if (authState.isAuthenticated) ...[
              SideMenuTile(
                icon: const Icon(Icons.favorite_outline),
                title: Text('profile.favorites'.tr()),
                onTap: () {
                  goToFavoritesPage(context, booruConfig.login);
                },
              ),
              SideMenuTile(
                icon: const Icon(Icons.collections),
                title: const Text('favorite_groups.favorite_groups').tr(),
                onTap: () {
                  goToFavoriteGroupPage(context);
                },
              ),
              SideMenuTile(
                icon: const Icon(Icons.search),
                title: const Text('saved_search.saved_search').tr(),
                onTap: () {
                  goToSavedSearchPage(context, booruConfig.login);
                },
              ),
              SideMenuTile(
                icon: const FaIcon(FontAwesomeIcons.ban, size: 20),
                title: const Text(
                  'blacklisted_tags.blacklisted_tags',
                ).tr(),
                onTap: () {
                  goToBlacklistedTagPage(context);
                },
              ),
            ]
          ],
        ),
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: LatestView(
                toolbarBuilder: (context) => SliverAppBar(
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  toolbarHeight: kToolbarHeight * 1.2,
                  primary: true,
                  title: HomeSearchBar(
                    onMenuTap: controller.openMenu,
                    onTap: () => goToSearchPage(context),
                  ),
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNavigationTile extends StatelessWidget {
  const HomeNavigationTile({
    super.key,
    this.onTap,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.value,
    required this.constraints,
    required this.controller,
  });

  // Will override the onTap function
  final VoidCallback? onTap;
  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final int value;
  final BoxConstraints constraints;
  final HomePageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, index, child) => NavigationTile(
        value: value,
        index: index,
        showIcon: constraints.maxWidth > 200 || constraints.maxWidth <= 62,
        showTitle: constraints.maxWidth > 62,
        selectedIcon: selectedIcon,
        icon: icon,
        title: Text(
          title,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: (value) => onTap != null ? onTap!() : controller.goToTab(value),
      ),
    );
  }
}
