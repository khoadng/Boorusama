// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/ref.dart';
import '../../core/posts/explores/widgets.dart';
import '../../core/posts/listing/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/widgets/booru_segmented_button.dart';
import 'providers.dart';

final _eroticOnProvider = StateProvider<bool>((ref) => false);

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: EroticsToggleSwitch(
                onToggle: (erotic) {
                  ref.read(_eroticOnProvider.notifier).state = erotic;
                },
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: _DailyPopularExplore(
            onPressed: (posts) => goToAnimePicturesDetailsTopPage(
              context,
              posts,
              'Daily Top',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _WeeklyPopularExplore(
            onPressed: (posts) => goToAnimePicturesDetailsTopPage(
              context,
              posts,
              'Weekly Top',
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
) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (_) => AnimePicturesDetailsTopPage(
        posts: posts,
        title: title,
      ),
    ),
  );
}

class AnimePicturesDetailsTopPage extends ConsumerWidget {
  const AnimePicturesDetailsTopPage({
    super.key,
    required this.posts,
    required this.title,
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

class EroticsToggleSwitch extends StatelessWidget {
  const EroticsToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(bool erotic) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: false,
        fixedWidth: 120,
        segments: const {
          false: 'Common',
          true: 'Erotics',
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

class _DailyPopularExplore extends ConsumerStatefulWidget {
  const _DailyPopularExplore({
    required this.onPressed,
  });

  final void Function(List<Post> posts) onPressed;

  @override
  ConsumerState<_DailyPopularExplore> createState() => _PopularExploreState();
}

class _PopularExploreState extends ConsumerState<_DailyPopularExplore> {
  @override
  Widget build(BuildContext context) {
    final params = (
      config: ref.watchConfigAuth,
      erotic: ref.watch(_eroticOnProvider),
    );

    return ExploreSection(
      title: 'Daily',
      builder: (_) =>
          ref.watch(animePicturesDailyPopularProvider(params)).maybeWhen(
                data: (r) => ExploreList(posts: r),
                orElse: () => const ExploreList(posts: []),
              ),
      onPressed: ref.watch(animePicturesDailyPopularProvider(params)).maybeWhen(
            data: (r) => () => widget.onPressed(r),
            orElse: () => null,
          ),
    );
  }
}

class _WeeklyPopularExplore extends ConsumerStatefulWidget {
  const _WeeklyPopularExplore({
    required this.onPressed,
  });

  final void Function(List<Post> posts) onPressed;

  @override
  ConsumerState<_WeeklyPopularExplore> createState() =>
      _WeeklyPopularExploreState();
}

class _WeeklyPopularExploreState extends ConsumerState<_WeeklyPopularExplore> {
  @override
  Widget build(BuildContext context) {
    final params = (
      config: ref.watchConfigAuth,
      erotic: ref.watch(_eroticOnProvider),
    );

    return ExploreSection(
      title: 'Weekly',
      builder: (_) =>
          ref.watch(animePicturesWeeklyPopularProvider(params)).maybeWhen(
                data: (r) => ExploreList(posts: r),
                orElse: () => const ExploreList(posts: []),
              ),
      onPressed:
          ref.watch(animePicturesWeeklyPopularProvider(params)).maybeWhen(
                data: (r) => () => widget.onPressed(r),
                orElse: () => null,
              ),
    );
  }
}
