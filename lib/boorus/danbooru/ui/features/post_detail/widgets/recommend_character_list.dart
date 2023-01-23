// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'recommend_section.dart';

class RecommendCharacterList extends StatelessWidget {
  const RecommendCharacterList({
    super.key,
    required this.recommends,
    this.useSeperator = false,
  });

  final bool useSeperator;
  final List<Recommend> recommends;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...recommends.map(
          (r) => RecommendPostSection(
            header: ListTile(
              onTap: () => goToCharacterPage(context, r.title),
              title: Text(r.title.removeUnderscoreWithSpace()),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            ),
            posts: r.posts,
            onTap: (index) => goToDetailPage(
              context: context,
              posts: r.posts,
              initialIndex: index,
            ),
          ),
        ),
      ],
    );
  }
}
