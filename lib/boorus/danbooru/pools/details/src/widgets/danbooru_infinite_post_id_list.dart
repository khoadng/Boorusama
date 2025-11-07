// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/errors/types.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/settings/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/providers.dart';
import '../../../../posts/post/types.dart';
import '../../../pool/types.dart';
import '../providers/filter_provider.dart';
import '../types/pool_posts_repo.dart';

class DanbooruInfinitePostIdList extends ConsumerWidget {
  const DanbooruInfinitePostIdList({
    required this.pool,
    super.key,
    this.sliverHeaders,
  });

  final DanbooruPool pool;
  final List<Widget>? sliverHeaders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );
    final config = ref.watchConfigSearch;
    final order = ref.watch(poolFilterProvider.select((state) => state.order));
    final repo = ref.watch(danbooruPostRepoProvider(config));

    return CustomContextMenuOverlay(
      child: PostScope<DanbooruPost>(
        fetcher: (page) => TaskEither.tryCatch(
          () => repo.fetchPoolPosts(
            pool: pool,
            page: page,
            perPage: perPage,
            order: order,
          ),
          (error, stackTrace) => UnknownError(error: error),
        ),
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
            ...?sliverHeaders,
          ],
        ),
      ),
    );
  }
}
