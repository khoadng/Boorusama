// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'explore_section.dart';

class ExplorePage extends StatelessWidget {
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
