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
          const SliverToBoxAdapter(child: _PopularExplore()),
          const SliverToBoxAdapter(child: _HotExplore()),
          const SliverToBoxAdapter(child: _MostViewedExplore()),
          const SliverSizedBox(height: kBottomNavigationBarHeight + 20),
        ],
      ),
    );
  }
}

class _MostViewedExplore extends ConsumerStatefulWidget {
  const _MostViewedExplore();

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
      onPressed: () => goToExploreMostViewedPage(context),
    );
  }
}

class _HotExplore extends ConsumerStatefulWidget {
  const _HotExplore();

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
      onPressed: () => goToExploreHotPage(context),
    );
  }
}

class _PopularExplore extends ConsumerStatefulWidget {
  const _PopularExplore();

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
      onPressed: () => goToExplorePopularPage(context),
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
                            style: context.textTheme.displayMedium!,
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
