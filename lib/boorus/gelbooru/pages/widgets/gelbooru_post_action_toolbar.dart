// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class GelbooruPostActionToolbar extends StatelessWidget {
  const GelbooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
          CommentPostButton(
            post: post,
            onPressed: () => goToGelbooruCommentsPage(context, post.id),
          ),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
