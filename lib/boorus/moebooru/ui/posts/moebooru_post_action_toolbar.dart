// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/posts.dart';

class MoebooruPostActionToolbar extends StatelessWidget {
  const MoebooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
