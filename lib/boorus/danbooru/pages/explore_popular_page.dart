// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/utils/duration_utils.dart';
import 'widgets/explores/explore_sliver_app_bar.dart';

class ExplorePopularPage extends ConsumerWidget {
  const ExplorePopularPage({
    super.key,
  });

  static Widget routeOf(BuildContext context) => CustomContextMenuOverlay(
        child: ProviderScope(
          overrides: [
            timeScaleProvider.overrideWith((ref) => TimeScale.day),
            dateProvider.overrideWith((ref) => DateTime.now()),
          ],
          child: const ExplorePopularPage(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAndDate = ref.watch(timeAndDateProvider);
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => ref
          .read(danbooruExploreRepoProvider(config))
          .getPopularPosts(timeAndDate.date, page, timeAndDate.scale),
      builder: (context, controller, errors) => _PopularContent(
        controller: controller,
        errors: errors,
      ),
    );
  }
}

class _PopularContent extends ConsumerWidget {
  const _PopularContent({
    required this.controller,
    this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleAndTime = ref.watch(timeAndDateProvider);

    ref.listen(
      timeAndDateProvider,
      (previous, next) async {
        if (previous != next) {
          // Delay 100ms, this is a hack
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return Container(
      color: context.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DanbooruInfinitePostList(
                errors: errors,
                controller: controller,
                safeArea: false,
                sliverHeaders: [
                  ExploreSliverAppBar(
                    title: 'explore.popular'.tr(),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        TimeScaleToggleSwitch(
                          onToggle: (scale) => ref
                              .read(timeScaleProvider.notifier)
                              .state = scale,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: context.theme.bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) =>
                    ref.read(dateProvider.notifier).state = date,
                date: scaleAndTime.date,
                scale: scaleAndTime.scale,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
