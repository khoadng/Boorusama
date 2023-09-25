// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/scaffolds/comment_page_scaffold.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';

class GelbooruCommentPage extends ConsumerWidget {
  const GelbooruCommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentPageScaffold(
      postId: postId,
      fetcher: (postId) =>
          ref.watch(gelbooruCommentRepoProvider).getComments(postId),
    );
  }
}
