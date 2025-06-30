// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/explores/widgets.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../listing/widgets.dart';
import '../../../post/post.dart';
import '../providers.dart';
import '../widgets/explore_sliver_app_bar.dart';

class ExploreMostViewedPage extends ConsumerStatefulWidget {
  const ExploreMostViewedPage({
    this.onBack,
    super.key,
  });

  final void Function()? onBack;

  @override
  ConsumerState<ExploreMostViewedPage> createState() =>
      _ExploreMostViewedPageState();
}

class _ExploreMostViewedPageState extends ConsumerState<ExploreMostViewedPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => page > 1
            ? TaskEither.fromEither(Either.of(<DanbooruPost>[].toResult()))
            : ref
                .read(danbooruExploreRepoProvider(config))
                .getMostViewedPosts(selectedDateNotifier.value),
        builder: (context, controller) => ColoredBox(
          color: Theme.of(context).colorScheme.surface,
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
                        title: 'explore.most_viewed'.tr(),
                        onBack: widget.onBack,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  child: ValueListenableBuilder(
                    valueListenable: selectedDateNotifier,
                    builder: (_, date, __) => DateTimeSelector(
                      onDateChanged: (date) {
                        selectedDateNotifier.value = date;
                        controller.refresh();
                      },
                      date: date,
                      backgroundColor: Colors.transparent,
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
