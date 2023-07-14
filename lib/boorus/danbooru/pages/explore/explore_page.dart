// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'explore_mixins.dart';
import 'explore_section.dart';

const double _kMaxHeight = 250;
const _padding = EdgeInsets.symmetric(horizontal: 2);

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

Widget mapToCarousel(
  BuildContext context,
  List<DanbooruPost> posts,
  WidgetRef ref,
) {
  return posts.isNotEmpty
      ? _ExploreList(
          posts: posts,
          onTap: (index) {
            goToDetailPage(
              context: context,
              posts: posts,
              initialIndex: index,
              hero: false,
            );
          },
        )
      : SizedBox(
          height: _kMaxHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 20,
            itemBuilder: (context, index) => Padding(
              padding: _padding,
              child: createRandomPlaceholderContainer(context),
            ),
          ),
        );
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
        .read(danbooruExploreRepoProvider)
        .getMostViewedPosts(DateTime.now())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider)
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
      builder: (_) => mapToCarousel(context, posts, ref),
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
        .read(danbooruExploreRepoProvider)
        .getHotPosts(page)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider)
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
      builder: (_) => mapToCarousel(context, posts, ref),
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
        .read(danbooruExploreRepoProvider)
        .getPopularPosts(DateTime.now(), page, TimeScale.day)
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ))
        .then((transform)),
    refresher: () => ref
        .read(danbooruExploreRepoProvider)
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
      builder: (_) => mapToCarousel(context, posts, ref),
      onPressed: () => goToExplorePopularPage(context),
    );
  }

  @override
  PostGridController<DanbooruPost> get controller => _controller;
}

class _ExploreList extends StatefulWidget {
  const _ExploreList({
    required this.posts,
    required this.onTap,
  });

  final List<DanbooruPost> posts;
  final void Function(int index) onTap;

  @override
  State<_ExploreList> createState() => _ExploreListState();
}

class _ExploreListState extends State<_ExploreList> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kMaxHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final posts = widget.posts;
          final post = posts[index];

          return Padding(
            padding: _padding,
            child: GestureDetector(
              onTap: () => widget.onTap(index),
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
        itemCount: widget.posts.length,
      ),
    );
  }
}
