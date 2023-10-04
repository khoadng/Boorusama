// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/posts/recommend_artist_list.dart';

class GelbooruRecommendedArtistList extends ConsumerWidget {
  const GelbooruRecommendedArtistList({
    super.key,
    required this.artists,
  });

  final List<Recommend<Post>> artists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RecommendArtistList(
      onHeaderTap: (index) =>
          goToGelbooruArtistPage(ref, context, artists[index].tag),
      onTap: (recommendIndex, postIndex) => goToPostDetailsPage(
        context: context,
        posts: artists[recommendIndex].posts,
        initialIndex: postIndex,
      ),
      recommends: artists,
      imageUrl: (item) => item.thumbnailImageUrl,
    );
  }
}
