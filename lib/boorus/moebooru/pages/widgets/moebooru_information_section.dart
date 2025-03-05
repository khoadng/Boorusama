// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/posts/details/details.dart';
import '../../../../core/posts/details_parts/widgets.dart';
import '../../../../core/router.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../feats/posts/posts.dart';
import '../../feats/tags/tags.dart';
import '../moebooru_post_details_page.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final config = ref.watchConfigAuth;

    return SliverToBoxAdapter(
      child: ref.watch(moebooruAllTagsProvider(config)).maybeWhen(
            data: (tags) {
              final tagGroups = createMoebooruTagGroupItems(post.tags, tags);

              return InformationSection(
                characterTags: tagGroups
                    .map((e) => e.extractCharacterTags())
                    .expand((e) => e)
                    .toSet(),
                artistTags: tagGroups
                    .map((e) => e.extractArtistTags())
                    .expand((e) => e)
                    .toSet(),
                copyrightTags: tagGroups
                    .map((e) => e.extractCopyRightTags())
                    .expand((e) => e)
                    .toSet(),
                createdAt: post.createdAt,
                source: post.source,
                onArtistTagTap: (context, artist) => goToArtistPage(
                  context,
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
