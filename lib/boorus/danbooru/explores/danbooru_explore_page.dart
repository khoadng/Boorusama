// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/explores/explores.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/explores/explore_page.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruExplorePage extends ConsumerWidget {
  const DanbooruExplorePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('explore.explore').tr(),
      ),
      body: const DanbooruExplorePageInternal(),
    );
  }
}

class DanbooruExplorePageInternal extends ConsumerWidget {
  const DanbooruExplorePageInternal({
    super.key,
    this.useAppBarPadding = true,
  });

  final bool useAppBarPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExplorePage(
      useAppBarPadding: useAppBarPadding,
      sliverOverviews: [
        SliverToBoxAdapter(
          child: _PopularExplore(
            onPressed: () => goToExplorePopularPage(context),
          ),
        ),
        SliverToBoxAdapter(
          child: _HotExplore(
            onPressed: () => goToExploreHotPage(context),
          ),
        ),
        SliverToBoxAdapter(
          child: _MostViewedExplore(
            onPressed: () => goToExploreMostViewedPage(context),
          ),
        ),
      ],
    );
  }
}

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
          child: _PopularExplore(
            onPressed: () =>
                controller.changeCategory(ExploreCategory.popular.name),
          ),
        ),
        SliverToBoxAdapter(
          child: _HotExplore(
            onPressed: () =>
                controller.changeCategory(ExploreCategory.hot.name),
          ),
        ),
        SliverToBoxAdapter(
          child: _MostViewedExplore(
            onPressed: () =>
                controller.changeCategory(ExploreCategory.mostViewed.name),
          ),
        ),
      ],
      details: ValueListenableBuilder(
        valueListenable: controller.selectedCategory,
        builder: (context, category, child) {
          return switch (category) {
            'popular' => ExplorePopularPage.routeOf(
                context,
                onBack: controller.back,
              ),
            'mostViewed' => ExploreMostViewedPage.routeOf(
                context,
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
    return ExploreSection(
      title: 'explore.most_viewed'.tr(),
      builder: (_) => ref.watch(danbooruMostViewedTodayProvider).maybeWhen(
            data: (r) => ExploreList(posts: r.posts),
            orElse: () => const ExploreList(posts: []),
          ),
      onPressed: widget.onPressed,
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
    return ExploreSection(
      title: 'explore.hot'.tr(),
      builder: (_) => ref.watch(danbooruHotTodayProvider).maybeWhen(
            data: (r) => ExploreList(posts: r.posts),
            orElse: () => const ExploreList(posts: []),
          ),
      onPressed: widget.onPressed,
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
    return ExploreSection(
      title: 'explore.popular'.tr(),
      builder: (_) => ref.watch(danbooruPopularTodayProvider).maybeWhen(
            data: (r) => ExploreList(posts: r.posts),
            orElse: () => const ExploreList(posts: []),
          ),
      onPressed: widget.onPressed,
    );
  }
}
