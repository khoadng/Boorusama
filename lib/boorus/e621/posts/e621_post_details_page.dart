// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/artists/artists.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'posts.dart';

class E621ArtistSection extends ConsumerWidget {
  const E621ArtistSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<E621Post>(context);

    final commentary = post.description;

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(commentary),
        artistTags: post.artistTags,
        source: post.source,
      ),
    );
  }
}
