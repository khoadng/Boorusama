// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...recommends.map(
          (r) => RecommendPostSection(
            header: header?.call(r.title) ??
                ListTile(
                  onTap: () => goToArtistPage(context, r.title),
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
