// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../listing/widgets.dart';
import '../providers.dart';
import '../widgets/explore_sliver_app_bar.dart';

class ExploreHotPage extends ConsumerWidget {
  const ExploreHotPage({
    super.key,
    this.onBack,
  });

  final void Function()? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) =>
            ref.read(danbooruExploreRepoProvider(config)).getHotPosts(page),
        builder: (context, controller) => PostGrid(
          controller: controller,
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
              title: 'explore.hot'.tr(),
              onBack: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
