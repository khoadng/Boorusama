// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/explores/widgets.dart';
import '../providers.dart';

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
          child: PopularExplore(
            onPressed: () => goToExplorePopularPage(context),
          ),
        ),
        SliverToBoxAdapter(
          child: HotExplore(
            onPressed: () => goToExploreHotPage(context),
          ),
        ),
        SliverToBoxAdapter(
          child: MostViewedExplore(
            onPressed: () => goToExploreMostViewedPage(context),
          ),
        ),
      ],
    );
  }
}

class MostViewedExplore extends ConsumerStatefulWidget {
  const MostViewedExplore({
    super.key,
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<MostViewedExplore> createState() => _MostViewedExploreState();
}

class _MostViewedExploreState extends ConsumerState<MostViewedExplore> {
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

class HotExplore extends ConsumerStatefulWidget {
  const HotExplore({
    super.key,
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<HotExplore> createState() => _HotExploreState();
}

class _HotExploreState extends ConsumerState<HotExplore> {
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

class PopularExplore extends ConsumerStatefulWidget {
  const PopularExplore({
    super.key,
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<PopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends ConsumerState<PopularExplore> {
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
