// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/explores/widgets.dart';
import '../types/explore_category.dart';
import 'danbooru_explore_page.dart';
import 'explore_hot_page.dart';
import 'explore_most_viewed_page.dart';
import 'explore_popular_page.dart';

class DanbooruExplorePageDesktop extends ConsumerStatefulWidget {
  const DanbooruExplorePageDesktop({
    super.key,
  });

  @override
  ConsumerState<DanbooruExplorePageDesktop> createState() =>
      _DanbooruExplorePageDesktopState();
}

class _DanbooruExplorePageDesktopState
    extends ConsumerState<DanbooruExplorePageDesktop> {
  final controller = ExplorePageDesktopController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorePageDesktop(
      controller: controller,
      sliverOverviews: [
        SliverToBoxAdapter(
          child: PopularExplore(
            onPressed: () => controller.category = ExploreCategory.popular.name,
          ),
        ),
        SliverToBoxAdapter(
          child: HotExplore(
            onPressed: () => controller.category = ExploreCategory.hot.name,
          ),
        ),
        SliverToBoxAdapter(
          child: MostViewedExplore(
            onPressed: () =>
                controller.category = ExploreCategory.mostViewed.name,
          ),
        ),
      ],
      details: ValueListenableBuilder(
        valueListenable: controller.selectedCategory,
        builder: (context, category, child) {
          return switch (category) {
            'popular' => ExplorePopularPage(
                onBack: controller.back,
              ),
            'mostViewed' => ExploreMostViewedPage(
                onBack: controller.back,
              ),
            _ => ExploreHotPage(
                onBack: controller.back,
              ),
          };
        },
      ),
    );
  }
}
