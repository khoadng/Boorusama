// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/posts/explores/widgets.dart';
import '../providers.dart';
import '../routes/route_utils.dart';

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
            onPressed: () => goToExplorePopularPage(ref),
          ),
        ),
        SliverToBoxAdapter(
          child: HotExplore(
            onPressed: () => goToExploreHotPage(ref),
          ),
        ),
        SliverToBoxAdapter(
          child: MostViewedExplore(
            onPressed: () => goToExploreMostViewedPage(ref),
          ),
        ),
      ],
    );
  }
}

class MostViewedExplore extends ConsumerStatefulWidget {
  const MostViewedExplore({
    required this.onPressed,
    super.key,
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
    required this.onPressed,
    super.key,
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
    required this.onPressed,
    super.key,
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
