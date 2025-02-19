// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/explores/explore.dart';
import '../../../../../../core/posts/explores/widgets.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../listing/widgets.dart';
import '../providers.dart';
import '../widgets/explore_sliver_app_bar.dart';

class ExplorePopularPage extends ConsumerStatefulWidget {
  const ExplorePopularPage({
    this.onBack,
    super.key,
  });

  final void Function()? onBack;

  @override
  ConsumerState<ExplorePopularPage> createState() => _ExplorePopularPageState();
}

class _ExplorePopularPageState extends ConsumerState<ExplorePopularPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  final selectedTimescale = ValueNotifier(TimeScale.day);

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) =>
            ref.read(danbooruExploreRepoProvider(config)).getPopularPosts(
                  selectedDateNotifier.value,
                  page,
                  selectedTimescale.value,
                ),
        builder: (context, controller) => ColoredBox(
          color: colorScheme.surface,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PostGrid(
                    controller: controller,
                    safeArea: false,
                    itemBuilder: (
                      context,
                      index,
                      multiSelectController,
                      scrollController,
                      useHero,
                    ) =>
                        DefaultDanbooruImageGridItem(
                      index: index,
                      multiSelectController: multiSelectController,
                      autoScrollController: scrollController,
                      controller: controller,
                      useHero: useHero,
                    ),
                    sliverHeaders: [
                      ExploreSliverAppBar(
                        title: 'explore.popular'.tr(),
                        onBack: widget.onBack,
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            TimeScaleToggleSwitch(
                              onToggle: (scale) {
                                selectedTimescale.value = scale;
                                controller.refresh();
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ColoredBox(
                  color: colorScheme.surfaceContainer,
                  child: ValueListenableBuilder(
                    valueListenable: selectedDateNotifier,
                    builder: (_, date, __) => ValueListenableBuilder(
                      valueListenable: selectedTimescale,
                      builder: (_, scale, __) => DateTimeSelector(
                        onDateChanged: (date) {
                          selectedDateNotifier.value = date;
                          controller.refresh();
                        },
                        date: date,
                        scale: scale,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
