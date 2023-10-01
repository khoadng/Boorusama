// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/posts/recommend_character_list.dart';

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
      onTap: (recommendIndex, postIndex) => goToPostDetailsPage(
        context: context,
        posts: characters[recommendIndex].posts,
        initialIndex: postIndex,
      ),
      recommends: characters,
      imageUrl: (item) => item.url360x360,
    );
  }
}
