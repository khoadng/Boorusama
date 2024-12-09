// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/datetimes/datetime_selector.dart';
import 'package:boorusama/core/posts/listing/providers.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import '../../../listing/widgets.dart';
import '../../../post/post.dart';
import '../providers.dart';
import '../widgets/explore_sliver_app_bar.dart';

class ExploreMostViewedPage extends ConsumerWidget {
  const ExploreMostViewedPage({
    super.key,
    required this.onBack,
  });

  final void Function()? onBack;

  static Widget routeOf(
    BuildContext context, {
    void Function()? onBack,
  }) =>
      CustomContextMenuOverlay(
        child: ProviderScope(
          overrides: [
            dateProvider.overrideWith((ref) => DateTime.now()),
          ],
          child: ExploreMostViewedPage(
            onBack: onBack,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);
    final config = ref.watchConfigSearch;

    return PostScope(
      fetcher: (page) => page > 1
          ? TaskEither.fromEither(Either.of(<DanbooruPost>[].toResult()))
          : ref
              .read(danbooruExploreRepoProvider(config))
              .getMostViewedPosts(date),
      builder: (context, controller) => _MostViewedContent(
        controller: controller,
        onBack: onBack,
      ),
    );
  }
}

class _MostViewedContent extends ConsumerWidget {
  const _MostViewedContent({
    required this.controller,
    required this.onBack,
  });

  final PostGridController<DanbooruPost> controller;
  final void Function()? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    ref.listen(
      dateProvider,
      (previous, next) async {
        if (previous != next) {
          // Delay 100ms, this is a hack
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PostGrid(
                controller: controller,
                safeArea: false,
                itemBuilder:
                    (context, index, multiSelectController, scrollController) =>
                        DefaultDanbooruImageGridItem(
                  index: index,
                  multiSelectController: multiSelectController,
                  autoScrollController: scrollController,
                  controller: controller,
                ),
                sliverHeaders: [
                  ExploreSliverAppBar(
                    title: 'explore.most_viewed'.tr(),
                    onBack: onBack,
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) =>
                    ref.read(dateProvider.notifier).state = date,
                date: date,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
