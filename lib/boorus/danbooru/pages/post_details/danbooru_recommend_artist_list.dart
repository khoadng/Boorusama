import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/posts/recommend_artist_list.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:flutter/material.dart';

class DanbooruRecommendArtistList extends StatelessWidget {
  const DanbooruRecommendArtistList({
    super.key,
    required this.artists,
  });

  final List<Recommend<DanbooruPost>> artists;

  @override
  Widget build(BuildContext context) {
    return RecommendArtistList(
      onTap: (recommendIndex, postIndex) => goToDetailPage(
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
