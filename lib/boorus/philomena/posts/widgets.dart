// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/artists/types.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'types.dart';

class PhilomenaStatsTileSection extends ConsumerWidget {
  const PhilomenaStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: SimplePostStatsTile(
        totalComments: post.commentCount,
        favCount: post.favCount,
        score: post.score,
        votePercentText: _generatePercentText(post),
      ),
    );
  }

  String _generatePercentText(PhilomenaPost? post) {
    if (post == null) return '';
    final percent = post.score > 0 ? (post.upvotes / post.score) : 0;
    return post.score > 0 ? '(${(percent * 100).toInt()}% upvoted)' : '';
  }
}

class PhilomenaArtistInfoSection extends ConsumerWidget {
  const PhilomenaArtistInfoSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<PhilomenaPost>(context);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ArtistCommentary.description(post.description),
        artistTags: post.artistTags ?? {},
        source: post.source,
      ),
    );
  }
}
