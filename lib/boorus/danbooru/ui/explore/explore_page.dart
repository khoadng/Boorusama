// Flutter imports:
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/boorus/current_booru_config_repository.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/utils.dart';
import 'explore_section.dart';

const double _kMaxHeight = 250;
const _padding = EdgeInsets.symmetric(horizontal: 2);

class ExplorePage extends StatelessWidget {
  const ExplorePage({
    super.key,
    this.useAppBarPadding = true,
  });

  final bool useAppBarPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Screen.of(context).size == ScreenSize.small
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        primary: false,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  useAppBarPadding ? MediaQuery.of(context).viewPadding.top : 0,
            ),
          ),
          const SliverToBoxAdapter(child: _PopularExplore()),
          const SliverToBoxAdapter(child: _HotExplore()),
          const SliverToBoxAdapter(child: _MostViewedExplore()),
          const SliverToBoxAdapter(
            child: SizedBox(height: kBottomNavigationBarHeight + 20),
          ),
        ],
      ),
    );
  }
}

Widget mapToCarousel(
  BuildContext context,
  List<DanbooruPost> posts,
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
              // postBloc: explore.bloc,
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

class _MostViewedExplore extends StatefulWidget {
  const _MostViewedExplore();

  @override
  State<_MostViewedExplore> createState() => _MostViewedExploreState();
}

class _MostViewedExploreState extends State<_MostViewedExplore>
    with DanbooruPostCubitMixin, DanbooruPostTransformMixin {
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (_) => context
        .read<ExploreRepository>()
        .getMostViewedPosts(DateTime.now())
        .then((transform)),
    refresher: () => context
        .read<ExploreRepository>()
        .getMostViewedPosts(DateTime.now())
        .then((transform)),
  );

  var posts = <DanbooruPost>[];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    controller.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChange);
    controller.dispose();
  }

  void _onControllerChange() {
    if (controller.items.isNotEmpty) {
      setState(() {
        posts = controller.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      controller: controller,
      date: DateTime.now(),
      title: 'explore.most_viewed'.tr(),
      category: ExploreCategory.mostViewed,
      builder: (_) => mapToCarousel(context, posts),
    );
  }

  @override
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  @override
  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  @override
  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  @override
  FavoritePostCubit get favoriteCubit => context.read<FavoritePostCubit>();

  @override
  PoolRepository get poolRepository => context.read<PoolRepository>();

  @override
  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  @override
  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  @override
  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
}

class _HotExplore extends StatefulWidget {
  const _HotExplore();

  @override
  State<_HotExplore> createState() => _HotExploreState();
}

class _HotExploreState extends State<_HotExplore>
    with DanbooruPostCubitMixin, DanbooruPostTransformMixin {
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) =>
        context.read<ExploreRepository>().getHotPosts(page).then((transform)),
    refresher: () =>
        context.read<ExploreRepository>().getHotPosts(1).then((transform)),
  );

  var posts = <DanbooruPost>[];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    controller.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChange);
    controller.dispose();
  }

  void _onControllerChange() {
    if (controller.items.isNotEmpty) {
      setState(() {
        posts = controller.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      controller: controller,
      date: DateTime.now(),
      title: 'explore.hot'.tr(),
      category: ExploreCategory.hot,
      builder: (_) => mapToCarousel(context, posts),
    );
  }

  @override
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  @override
  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  @override
  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  @override
  FavoritePostCubit get favoriteCubit => context.read<FavoritePostCubit>();

  @override
  PoolRepository get poolRepository => context.read<PoolRepository>();

  @override
  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  @override
  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  @override
  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
}

class _PopularExplore extends StatefulWidget {
  const _PopularExplore();

  @override
  State<_PopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends State<_PopularExplore>
    with DanbooruPostCubitMixin, DanbooruPostTransformMixin {
  late final controller = PostGridController<DanbooruPost>(
    fetcher: (page) => context
        .read<ExploreRepository>()
        .getPopularPosts(DateTime.now(), page, TimeScale.day)
        .then((transform)),
    refresher: () => context
        .read<ExploreRepository>()
        .getPopularPosts(DateTime.now(), 1, TimeScale.day)
        .then((transform)),
  );

  var posts = <DanbooruPost>[];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    controller.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChange);
    controller.dispose();
  }

  void _onControllerChange() {
    if (controller.items.isNotEmpty) {
      setState(() {
        posts = controller.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      controller: controller,
      date: DateTime.now(),
      title: 'explore.popular'.tr(),
      category: ExploreCategory.popular,
      builder: (_) => mapToCarousel(context, posts),
    );
  }

  @override
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  @override
  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  @override
  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  @override
  FavoritePostCubit get favoriteCubit => context.read<FavoritePostCubit>();

  @override
  PoolRepository get poolRepository => context.read<PoolRepository>();

  @override
  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  @override
  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  @override
  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
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
                    imageUrl: post.isAnimated
                        ? post.thumbnailImageUrl
                        : post.sampleImageUrl,
                    placeholderUrl: post.thumbnailImageUrl,
                  ),
                  Positioned.fill(
                    child: ShadowGradientOverlay(
                      alignment: Alignment.bottomCenter,
                      colors: <Color>[
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
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
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
