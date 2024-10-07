// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/anime-pictures/providers.dart';
import 'package:boorusama/boorus/danbooru/explores/explore_section.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/explores/explores.dart';

class AnimePicturesTopPage extends ConsumerWidget {
  const AnimePicturesTopPage({
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
          child: _DailyPopularExplore(
            onPressed: () => print('Daily Popular'),
          ),
        ),
        SliverToBoxAdapter(
          child: _WeeklyPopularExplore(
            onPressed: () => print('Weekly Popular'),
          ),
        ),
      ],
    );
  }
}

class _DailyPopularExplore extends ConsumerStatefulWidget {
  const _DailyPopularExplore({
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<_DailyPopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends ConsumerState<_DailyPopularExplore> {
  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      title: 'Daily Popular',
      builder: (_) => ref
          .watch(animePicturesDailyPopularProvider(ref.watchConfig))
          .maybeWhen(
            data: (r) => ExploreList(posts: r),
            orElse: () => const ExploreList(posts: []),
          ),
      onPressed: widget.onPressed,
    );
  }
}

class _WeeklyPopularExplore extends ConsumerStatefulWidget {
  const _WeeklyPopularExplore({
    required this.onPressed,
  });

  final void Function() onPressed;

  @override
  ConsumerState<_WeeklyPopularExplore> createState() =>
      _WeeklyPopularExploreState();
}

class _WeeklyPopularExploreState extends ConsumerState<_WeeklyPopularExplore> {
  @override
  Widget build(BuildContext context) {
    return ExploreSection(
      title: 'Weekly Popular',
      builder: (_) => ref
          .watch(animePicturesWeeklyPopularProvider(ref.watchConfig))
          .maybeWhen(
            data: (r) => ExploreList(posts: r),
            orElse: () => const ExploreList(posts: []),
          ),
      onPressed: widget.onPressed,
    );
  }
}
