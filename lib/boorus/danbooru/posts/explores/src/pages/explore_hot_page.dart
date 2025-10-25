// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
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
          itemBuilder: (context, index, scrollController, useHero) =>
              DanbooruPostListingContextMenu(
                index: index,
                controller: controller,
                child: DefaultDanbooruImageGridItem(
                  index: index,
                  autoScrollController: scrollController,
                  controller: controller,
                  useHero: useHero,
                ),
              ),
          sliverHeaders: [
            ExploreSliverAppBar(
              title: context.t.explore.hot,
              onBack: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
