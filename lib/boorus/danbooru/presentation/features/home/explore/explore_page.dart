// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/curated_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/explore_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/most_viewed_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/popular_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/carousel_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'explore_section.dart';

class ExplorePage extends HookWidget {
  const ExplorePage({Key? key}) : super(key: key);

  Widget mapStateToCarousel(
      BuildContext context, AsyncLoadState<List<Post>> state) {
    if (state.status == LoadStatus.success) {
      if (state.data!.isEmpty) return const CarouselPlaceholder();
      return _ExploreCarousel(posts: state.data!);
    } else if (state.status == LoadStatus.failure) {
      return const Center(
        child: Text('Something went wrong'),
      );
    } else {
      return const CarouselPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      //TODO: doesn't looks good without some images slapped on it
      // popularSearch.maybeWhen(
      //   data: (searches) => SliverPadding(
      //     padding: const EdgeInsets.all(10.0),
      //     sliver: SliverGrid.count(
      //       mainAxisSpacing: 8,
      //       crossAxisSpacing: 8,
      //       childAspectRatio: 4.5,
      //       crossAxisCount: 2,
      //       children: searches
      //           .take(10)
      //           .map(
      //             (search) => Container(
      //                 decoration: BoxDecoration(
      //                   color: Theme.of(context).accentColor,
      //                   borderRadius: BorderRadius.circular(8.0),
      //                 ),
      //                 child: Center(child: const Text("#${search.keyword.removeUnderscoreWithSpace()}"))),
      //           )
      //           .toList(),
      //     ),
      //   ),
      //   orElse: () => SliverToBoxAdapter(
      //     child: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   ),
      // ),

      SliverToBoxAdapter(
        child: ExploreSection(
          title: 'Popular',
          category: ExploreCategory.popular,
          builder: (_) => BlocBuilder<PopularCubit, AsyncLoadState<List<Post>>>(
            builder: mapStateToCarousel,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ExploreSection(
          title: 'Curated',
          category: ExploreCategory.curated,
          builder: (_) => BlocBuilder<CuratedCubit, AsyncLoadState<List<Post>>>(
            builder: mapStateToCarousel,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: ExploreSection(
          title: 'Most viewed',
          category: ExploreCategory.mostViewed,
          builder: (_) =>
              BlocBuilder<MostViewedCubit, AsyncLoadState<List<Post>>>(
            builder: mapStateToCarousel,
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
        ),
      ),
    ]);
  }
}

class _ExploreCarousel extends StatelessWidget {
  const _ExploreCarousel({
    Key? key,
    required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: posts.length,
      itemBuilder: (context, index, realIndex) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => AppRouter.router.navigateTo(
            context,
            '/post/detail',
            routeSettings: RouteSettings(
              arguments: [
                posts,
                index,
              ],
            ),
          ),
          child: Stack(
            children: [
              PostImage(
                imageUrl: post.isAnimated
                    ? post.previewImageUrl
                    : post.normalImageUrl,
                placeholderUrl: post.previewImageUrl,
              ),
              ShadowGradientOverlay(
                alignment: Alignment.bottomCenter,
                colors: <Color>[
                  const Color(0xC2000000),
                  Colors.black12.withOpacity(0)
                ],
              ),
              Align(
                alignment: const Alignment(-0.9, 1),
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 1.5,
        viewportFraction: 0.5,
        enlargeCenterPage: true,
      ),
    );
  }
}
