// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'explore_carousel.dart';
import 'explore_section.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  Widget mapStateToCarousel(
      BuildContext context, AsyncLoadState<List<Post>> state) {
    if (state.status == LoadStatus.success) {
      if (state.data!.isEmpty) return const CarouselPlaceholder();
      return ExploreCarousel(posts: state.data!);
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
    return CustomScrollView(
      primary: false,
      slivers: [
        SliverToBoxAdapter(
          child: ExploreSection(
            title: 'explore.popular'.tr(),
            category: ExploreCategory.popular,
            builder: (_) =>
                BlocBuilder<PopularCubit, AsyncLoadState<List<Post>>>(
              builder: mapStateToCarousel,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ExploreSection(
            title: 'explore.curated'.tr(),
            category: ExploreCategory.curated,
            builder: (_) =>
                BlocBuilder<CuratedCubit, AsyncLoadState<List<Post>>>(
              builder: mapStateToCarousel,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ExploreSection(
            title: 'explore.most_viewed'.tr(),
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
      ],
    );
  }
}
