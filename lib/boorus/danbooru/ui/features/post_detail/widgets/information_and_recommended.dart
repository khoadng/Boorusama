// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'post_action_toolbar.dart';
import 'recommend_section.dart';

class RecommendArtistList extends StatelessWidget {
  const RecommendArtistList({
    Key? key,
    required this.recommends,
    this.header,
    this.useSeperator = false,
  }) : super(key: key);

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
                  onTap: () => AppRouter.router.navigateTo(
                    context,
                    '/artist',
                    routeSettings: RouteSettings(
                      arguments: [
                        r.title,
                        '',
                      ],
                    ),
                  ),
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

class RecommendCharacterList extends StatelessWidget {
  const RecommendCharacterList({
    Key? key,
    required this.recommends,
    this.useSeperator = false,
  }) : super(key: key);

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
              onTap: () => AppRouter.router.navigateTo(
                context,
                '/character',
                routeSettings: RouteSettings(
                  arguments: [
                    r.title,
                    '',
                  ],
                ),
              ),
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

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.imagePath,
    required this.postData,
  }) : super(key: key);

  final ValueNotifier<String?> imagePath;
  final PostData postData;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        postData: postData,
        imagePath: value,
      ),
    );
  }
}
