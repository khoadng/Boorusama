// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../routers/routers.dart';
import '../../../../tags/categories/tag_category.dart';
import '../../../../tags/tag/tag.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../../theme.dart';
import '../../../details_parts/widgets.dart';
import '../../../post/post.dart';

class DefaultImagePreviewQuickActionButton extends ConsumerWidget {
  const DefaultImagePreviewQuickActionButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final booruBuilder = ref.watch(booruBuilderProvider(config.auth));

    return switch (config.defaultPreviewImageButtonActionType) {
      ImageQuickActionType.bookmark => Container(
        padding: const EdgeInsets.only(
          top: 2,
          bottom: 1,
          right: 1,
          left: 3,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.extendedColorScheme.surfaceContainerOverlay,
        ),
        child: BookmarkPostLikeButtonButton(
          post: post,
        ),
      ),
      ImageQuickActionType.download => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.extendedColorScheme.surfaceContainerOverlay,
        ),
        child: DownloadPostButton(
          post: post,
          small: true,
        ),
      ),
      ImageQuickActionType.artist => Builder(
        builder: (context) {
          final artist = post.artistTags != null && post.artistTags!.isNotEmpty
              ? chooseArtistTag(post.artistTags!)
              : null;
          if (artist == null) return const SizedBox.shrink();

          return PostTagListChip(
            tag: Tag.noCount(
              name: artist,
              category: TagCategory.artist(),
            ),
            auth: config.auth,
            onTap: () => goToArtistPage(
              ref,
              artist,
            ),
          );
        },
      ),
      ImageQuickActionType.defaultAction =>
        booruBuilder?.quickFavoriteButtonBuilder != null
            ? booruBuilder!.quickFavoriteButtonBuilder!(
                context,
                post,
              )
            : const SizedBox.shrink(),
      ImageQuickActionType.none => const SizedBox.shrink(),
    };
  }
}
