// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/widgets/posts/information_section.dart';

class MoebooruInformationSection extends ConsumerWidget {
  const MoebooruInformationSection({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    final characterTags =
        tags?.map((e) => e.extractCharacterTags()).expand((e) => e).toList();
    final artistTags =
        tags?.map((e) => e.extractArtistTags()).expand((e) => e).toList();
    final copyRightTags =
        tags?.map((e) => e.extractCopyRightTags()).expand((e) => e).toList();

    return InformationSection(
      characterTags: characterTags ?? [],
      artistTags: artistTags ?? [],
      copyrightTags: copyRightTags ?? [],
      createdAt: post.createdAt ?? DateTime.now(),
      source: post.source,
    );
  }
}
