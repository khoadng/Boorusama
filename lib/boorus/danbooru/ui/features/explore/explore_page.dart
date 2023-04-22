// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
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

class _MostViewedExplore extends StatelessWidget {
  const _MostViewedExplore();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DanbooruMostViewedExplorePostCubit,
        DanbooruExplorePostState>(
      builder: (context, state) {
        return ExploreSection(
          date: DateTime.now(),
          title: 'explore.most_viewed'.tr(),
          category: ExploreCategory.mostViewed,
          builder: (_) => mapToCarousel(context, state.data),
        );
      },
    );
  }
}

class _HotExplore extends StatelessWidget {
  const _HotExplore();

  @override
  Widget build(BuildContext context) {
    // final hot = context.select((ExploreBloc bloc) => bloc.state.hot);

    return BlocBuilder<DanbooruHotExplorePostCubit, DanbooruExplorePostState>(
      builder: (context, state) {
        return ExploreSection(
          date: DateTime.now(),
          title: 'explore.hot'.tr(),
          category: ExploreCategory.hot,
          builder: (_) => mapToCarousel(context, state.data),
        );
      },
    );
  }
}

class _PopularExplore extends StatelessWidget {
  const _PopularExplore();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DanbooruPopularExplorePostCubit,
        DanbooruExplorePostState>(
      builder: (context, state) {
        return ExploreSection(
          date: DateTime.now(),
          title: 'explore.popular'.tr(),
          category: ExploreCategory.popular,
          builder: (_) => mapToCarousel(context, state.data),
        );
      },
    );
  }
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
