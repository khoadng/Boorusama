// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/listing/default_danbooru_image_grid_item.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/listing.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'explore_sliver_app_bar.dart';
import 'providers.dart';

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
              title: 'explore.hot'.tr(),
              onBack: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
