// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/posts/recommend_character_list.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class DanbooruRecommendCharacterList extends StatelessWidget {
  const DanbooruRecommendCharacterList({
    super.key,
    required this.characters,
  });

  final List<Recommend<DanbooruPost>> characters;

  @override
  Widget build(BuildContext context) {
    return RecommendCharacterList(
      onHeaderTap: (index) => goToCharacterPage(context, characters[index].tag),
      onTap: (recommendIndex, postIndex) => goToDetailPage(
        context: context,
        posts: characters[recommendIndex].posts,
        initialIndex: postIndex,
        hero: false,
      ),
      recommends: characters,
      imageUrl: (item) => item.url360x360,
    );
  }
}
