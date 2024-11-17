// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/router.dart';
import '../moebooru_post_details_page.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final config = ref.watchConfig;

    return ref.watch(moebooruAllTagsProvider(config)).maybeWhen(
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
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}
