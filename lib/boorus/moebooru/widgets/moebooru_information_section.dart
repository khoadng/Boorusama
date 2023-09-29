// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/widgets/posts/information_section.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(currentBooruConfigProvider);
    final tags = ref.watch(tagsProvider(config));

    return InformationSection(
      characterTags: tags
              ?.map((e) => e.extractCharacterTags())
              .expand((e) => e)
              .toList() ??
          [],
      artistTags:
          tags?.map((e) => e.extractArtistTags()).expand((e) => e).toList() ??
              [],
      copyrightTags: tags
              ?.map((e) => e.extractCopyRightTags())
              .expand((e) => e)
              .toList() ??
          [],
      createdAt: post.createdAt,
      source: post.source,
    );
  }
}
