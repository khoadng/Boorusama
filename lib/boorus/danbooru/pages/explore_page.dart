// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/types.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/explores/explore_mixins.dart';
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
      padding: Screen.of(context).size == ScreenSize.small
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        primary: false,
        slivers: [
          SliverSizedBox(
            height:
                useAppBarPadding ? MediaQuery.of(context).viewPadding.top : 0,
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

class _MostViewedExploreState extends ConsumerState<_MostViewedExplore>
    with
        DanbooruPostTransformMixin,
        PostExplorerMixin<_MostViewedExplore, DanbooruPost>,
        DanbooruPostServiceProviderMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (_) => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getMostViewedPosts(DateTime.now())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getMostViewedPosts(DateTime.now())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
  );

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      title: 'explore.most_viewed'.tr(),
      builder: (_) => ExploreList(posts: posts),
      onPressed: () => goToExploreMostViewedPage(context),
    );
  }

  @override
  PostGridController<DanbooruPost> get controller => _controller;
}

class _HotExplore extends ConsumerStatefulWidget {
  const _HotExplore();

  @override
  ConsumerState<_HotExplore> createState() => _HotExploreState();
}

class _HotExploreState extends ConsumerState<_HotExplore>
    with
        DanbooruPostTransformMixin,
        PostExplorerMixin<_HotExplore, DanbooruPost>,
        DanbooruPostServiceProviderMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (page) => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getHotPosts(page)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getHotPosts(1)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
  );

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      title: 'explore.hot'.tr(),
      builder: (_) => ExploreList(posts: posts),
      onPressed: () => goToExploreHotPage(context),
    );
  }

  @override
  PostGridController<DanbooruPost> get controller => _controller;
}

class _PopularExplore extends ConsumerStatefulWidget {
  const _PopularExplore();

  @override
  ConsumerState<_PopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends ConsumerState<_PopularExplore>
    with
        DanbooruPostTransformMixin,
        PostExplorerMixin<_PopularExplore, DanbooruPost>,
        DanbooruPostServiceProviderMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (page) => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getPopularPosts(DateTime.now(), page, TimeScale.day)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider(ref.readConfig))
        .getPopularPosts(DateTime.now(), 1, TimeScale.day)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
  );

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      title: 'explore.popular'.tr(),
      builder: (_) => ExploreList(posts: posts),
      onPressed: () => goToExplorePopularPage(context),
    );
  }

  @override
  PostGridController<DanbooruPost> get controller => _controller;
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
                            style: context.textTheme.displayMedium!
                                .copyWith(color: Colors.white),
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
