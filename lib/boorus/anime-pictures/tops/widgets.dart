// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/explores/widgets.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/widgets/booru_segmented_button.dart';
import 'providers.dart';

class AnimePicturesTopPage extends ConsumerWidget {
  const AnimePicturesTopPage({
    super.key,
    this.useAppBarPadding = true,
  });

  final bool useAppBarPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return ExplorePage(
      useAppBarPadding: useAppBarPadding,
      sliverOverviews: [
        if (config.passHash != null)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: EroticsToggleSwitch(),
            ),
          ),
        SliverToBoxAdapter(
          child: _DailyPopularExplore(
            onPressed: (posts) => goToAnimePicturesDetailsTopPage(
              context,
              posts,
              'Daily Top',
              const RouteSettings(name: 'daily_top'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _WeeklyPopularExplore(
            onPressed: (posts) => goToAnimePicturesDetailsTopPage(
              context,
              posts,
              'Weekly Top',
              const RouteSettings(name: 'weekly_top'),
            ),
          ),
        ),
      ],
    );
  }
}

void goToAnimePicturesDetailsTopPage(
  BuildContext context,
  List<Post> posts,
  String title,
  RouteSettings settings,
) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      settings: settings,
      builder: (_) => AnimePicturesDetailsTopPage(
        posts: posts,
        title: title,
      ),
    ),
  );
}

class AnimePicturesDetailsTopPage extends ConsumerWidget {
  const AnimePicturesDetailsTopPage({
    required this.posts,
    required this.title,
    super.key,
  });

  final List<Post> posts;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SinglePagePostListScaffold(
        posts: posts,
      ),
    );
  }
}

class EroticsToggleSwitch extends ConsumerWidget {
  const EroticsToggleSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: ref.watch(eroticOnProvider),
        fixedWidth: 120,
        segments: const {
          false: 'Common',
          true: 'Erotics',
        },
        onChanged: (value) =>
            ref.read(eroticOnProvider.notifier).updateValue(value),
      ),
    );
  }
}

class _DailyPopularExplore extends ConsumerWidget {
  const _DailyPopularExplore({
    required this.onPressed,
  });

  final void Function(List<Post> posts) onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      config: ref.watchConfigAuth,
      erotic: ref.watch(eroticOnProvider),
    );

    final asyncValue = ref.watch(animePicturesDailyPopularProvider(params));

    return ExploreSection(
      title: context.t.explore.daily,
      builder: (_) => asyncValue.maybeWhen(
        data: (r) => ExploreList(posts: r),
        orElse: () => const ExploreList(posts: []),
      ),
      onPressed: asyncValue.maybeWhen(
        data: (r) =>
            () => onPressed(r),
        orElse: () => null,
      ),
    );
  }
}

class _WeeklyPopularExplore extends ConsumerWidget {
  const _WeeklyPopularExplore({
    required this.onPressed,
  });

  final void Function(List<Post> posts) onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      config: ref.watchConfigAuth,
      erotic: ref.watch(eroticOnProvider),
    );

    final asyncValue = ref.watch(animePicturesWeeklyPopularProvider(params));

    return ExploreSection(
      title: context.t.explore.weekly,
      builder: (_) => asyncValue.maybeWhen(
        data: (r) => ExploreList(posts: r),
        orElse: () => const ExploreList(posts: []),
      ),
      onPressed: asyncValue.maybeWhen(
        data: (r) =>
            () => onPressed(r),
        orElse: () => null,
      ),
    );
  }
}
