// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final r = recommends[index];
          return RecommendPostSection(
            grid: false,
            header: ListTile(
              onTap: () => goToCharacterPage(context, r.tag),
              title: Text(r.title),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            ),
            posts: r.posts,
            onTap: (index) => goToDetailPage(
              context: context,
              posts: r.posts,
              initialIndex: index,
              hero: false,
            ),
          );
        },
        childCount: recommends.length,
      ),
    );
  }
}
