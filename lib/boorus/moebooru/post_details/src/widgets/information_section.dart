// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/details/types.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/router.dart';
import '../../../../../core/tags/categories/types.dart';
import '../../../posts/types.dart';
import '../../../tags/providers.dart';
import '../../../tags/types.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final config = ref.watchConfigAuth;

    return SliverToBoxAdapter(
      child: ref
          .watch(moebooruAllTagsProvider(config))
          .maybeWhen(
            data: (allTagsMap) {
              return InformationSection(
                characterTags: extractMoebooruTagsByCategory(
                  post.tags,
                  allTagsMap,
                  TagCategory.character(),
                ),
                artistTags: extractMoebooruTagsByCategory(
                  post.tags,
                  allTagsMap,
                  TagCategory.artist(),
                ),
                copyrightTags: extractMoebooruTagsByCategory(
                  post.tags,
                  allTagsMap,
                  TagCategory.copyright(),
                ),
                createdAt: post.createdAt,
                source: post.source,
                onArtistTagTap: (context, artist) => goToArtistPage(
                  ref,
                  artist,
                ),
                showSource: true,
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
    );
  }
}
