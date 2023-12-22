// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'explore_hot_page.dart';
import 'explore_most_viewed_page.dart';
import 'explore_popular_page.dart';
import 'widgets/explores/explore_section.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({
    super.key,
    this.useAppBarPadding = true,
  });

  final bool useAppBarPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        primary: false,
        slivers: [
          SliverSizedBox(
            height:
                useAppBarPadding ? MediaQuery.viewPaddingOf(context).top : 0,
          ),
          SliverToBoxAdapter(
              child: _PopularExplore(
            onPressed: () => goToExplorePopularPage(context),
          )),
          SliverToBoxAdapter(
              child: _HotExplore(
            onPressed: () => goToExploreHotPage(context),
          )),
          SliverToBoxAdapter(
              child: _MostViewedExplore(
            onPressed: () => goToExploreMostViewedPage(context),
          )),
          const SliverSizedBox(height: kBottomNavigationBarHeight + 20),
        ],
      ),
    );
  }
}

final selectedExploreCategoryProvider =
    StateProvider.autoDispose<ExploreCategory?>((ref) {
  return null;
});

class ExplorePageDesktop extends ConsumerWidget {
  const ExplorePageDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedExploreCategoryProvider);

    return Stack(
      children: [
        Offstage(
          offstage: selectedCategory != null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomScrollView(
              primary: false,
              slivers: [
                SliverToBoxAdapter(
                    child: _PopularExplore(
                  onPressed: () => ref
                      .read(selectedExploreCategoryProvider.notifier)
                      .state = ExploreCategory.popular,
                )),
                SliverToBoxAdapter(
                    child: _HotExplore(
                  onPressed: () => ref
                      .read(selectedExploreCategoryProvider.notifier)
                      .state = ExploreCategory.hot,
                )),
                SliverToBoxAdapter(
                    child: _MostViewedExplore(
                  onPressed: () => ref
                      .read(selectedExploreCategoryProvider.notifier)
                      .state = ExploreCategory.mostViewed,
                )),
              ],
            ),
          ),
        ),
        Offstage(
          offstage: selectedCategory == null,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => ref
                    .read(selectedExploreCategoryProvider.notifier)
                    .state = null,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: switch (selectedCategory) {
              ExploreCategory.hot => ExploreHotPage.routeOf(context),
              ExploreCategory.mostViewed =>
                ExploreMostViewedPage.routeOf(context),
              ExploreCategory.popular => ExplorePopularPage.routeOf(context),
              null => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }
}

class _MostViewedExplore extends ConsumerStatefulWidget {
  const _MostViewedExplore({
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<_MostViewedExplore> createState() => _MostViewedExploreState();
}

class _MostViewedExploreState extends ConsumerState<_MostViewedExplore> {
  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(danbooruMostViewedTodayProvider);

    return ExploreSection(
      title: 'explore.most_viewed'.tr(),
      builder: (_) => postAsync.maybeWhen(
        data: (posts) => ExploreList(posts: posts),
        orElse: () => const ExploreList(posts: []),
      ),
      onPressed: () => widget.onPressed(),
    );
  }
}

class _HotExplore extends ConsumerStatefulWidget {
  const _HotExplore({
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<_HotExplore> createState() => _HotExploreState();
}

class _HotExploreState extends ConsumerState<_HotExplore> {
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(danbooruHotTodayProvider);

    return ExploreSection(
      title: 'explore.hot'.tr(),
      builder: (_) => posts.maybeWhen(
        data: (posts) => ExploreList(posts: posts),
        orElse: () => const ExploreList(posts: []),
      ),
      onPressed: () => widget.onPressed(),
    );
  }
}

class _PopularExplore extends ConsumerStatefulWidget {
  const _PopularExplore({
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<_PopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends ConsumerState<_PopularExplore> {
  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(danbooruPopularTodayProvider);

    return ExploreSection(
      title: 'explore.popular'.tr(),
      builder: (_) => postAsync.maybeWhen(
        data: (posts) => ExploreList(posts: posts),
        orElse: () => const ExploreList(posts: []),
      ),
      onPressed: () => widget.onPressed(),
    );
  }
}

class ExploreList extends ConsumerWidget {
  const ExploreList({
    super.key,
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = context.screen.size == ScreenSize.small ? 200.0 : 250.0;

    return posts.isNotEmpty
        ? SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => goToPostDetailsPage(
                      context: context,
                      posts: posts,
                      initialIndex: index,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BooruImage(
                          aspectRatio: post.aspectRatio,
                          imageUrl: post.url720x720,
                          placeholderUrl: post.thumbnailImageUrl,
                        ),
                        if (post.isAnimated)
                          Positioned(
                            top: 5,
                            left: 5,
                            child: VideoPlayDurationIcon(
                              duration: post.duration,
                              hasSound: post.hasSound,
                            ),
                          ),
                        Positioned.fill(
                          child: ShadowGradientOverlay(
                            alignment: Alignment.bottomCenter,
                            colors: [
                              const Color(0xC2000000),
                              Colors.black12.withOpacity(0),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 5,
                          bottom: 1,
                          child: Text(
                            '${index + 1}',
                            style: context.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: posts.length,
            ),
          )
        : SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: createRandomPlaceholderContainer(context),
              ),
            ),
          );
  }
}
