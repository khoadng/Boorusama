// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'recommend_section.dart';

class RecommendArtistList extends StatelessWidget {
  const RecommendArtistList({
    super.key,
    required this.recommends,
    this.header,
    this.useSeperator = false,
  });

  final List<Recommend> recommends;
  final Widget Function(String item)? header;
  final bool useSeperator;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final r = recommends[index];
          return RecommendPostSection(
            header: header?.call(r.title) ??
                ListTile(
                  onTap: () => goToArtistPage(context, r.tag),
                  title: Text(r.title),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                ),
            posts: r.posts,
            onTap: (index) => goToDetailPage(
              context: context,
              posts: r.posts,
              initialIndex: index,
            ),
          );
        },
        childCount: recommends.length,
      ),
    );
  }
}
