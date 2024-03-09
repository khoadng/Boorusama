// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
    required this.post,
    required this.tags,
  });

  final Post post;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InformationSection(
      characterTags:
          tags?.map((e) => e.extractCharacterTags()).expand((e) => e).toSet() ??
              {},
      artistTags:
          tags?.map((e) => e.extractArtistTags()).expand((e) => e).toSet() ??
              {},
      copyrightTags:
          tags?.map((e) => e.extractCopyRightTags()).expand((e) => e).toSet() ??
              {},
      createdAt: post.createdAt,
      source: post.source,
      onArtistTagTap: (context, artist) => goToArtistPage(
        context,
        artist,
      ),
    );
  }
}
