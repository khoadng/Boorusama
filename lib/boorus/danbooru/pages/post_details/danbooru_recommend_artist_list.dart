// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/posts/recommend_artist_list.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class DanbooruRecommendArtistList extends StatelessWidget {
  const DanbooruRecommendArtistList({
    super.key,
    required this.artists,
  });

  final List<Recommend<DanbooruPost>> artists;

  @override
  Widget build(BuildContext context) {
    return RecommendArtistList(
      onTap: (recommendIndex, postIndex) => goToPostDetailsPage(
        context: context,
        posts: artists[recommendIndex].posts,
        initialIndex: postIndex,
      ),
      onHeaderTap: (index) => goToArtistPage(context, artists[index].tag),
      recommends: artists,
      imageUrl: (item) => item.url360x360,
    );
  }
}
