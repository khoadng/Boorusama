// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/datetimes/datetime_selector.dart';
import '../../../../../../core/datetimes/time_scale_toggle_switch.dart';
import '../../../../../../core/datetimes/types.dart';
import '../../../../../../core/posts/listing/providers.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/utils/duration_utils.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../listing/widgets.dart';
import '../../../post/post.dart';
import '../providers.dart';
import '../widgets/explore_sliver_app_bar.dart';

class ExplorePopularPage extends ConsumerWidget {
  const ExplorePopularPage({
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
            timeScaleProvider.overrideWith((ref) => TimeScale.day),
            dateProvider.overrideWith((ref) => DateTime.now()),
          ],
          child: ExplorePopularPage(onBack: onBack),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAndDate = ref.watch(timeAndDateProvider);
    final config = ref.watchConfigSearch;

    return PostScope(
      fetcher: (page) => ref
          .read(danbooruExploreRepoProvider(config))
          .getPopularPosts(timeAndDate.date, page, timeAndDate.scale),
      builder: (context, controller) => _PopularContent(
        controller: controller,
        onBack: onBack,
      ),
    );
  }
}

class _PopularContent extends ConsumerWidget {
  const _PopularContent({
    required this.controller,
    required this.onBack,
  });

  final PostGridController<DanbooruPost> controller;
  final void Function()? onBack;

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
                    title: 'explore.popular'.tr(),
                    onBack: onBack,
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
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
