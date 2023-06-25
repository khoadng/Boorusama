// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/core/widgets/comment_header.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class DanbooruCommentHeader extends ConsumerWidget {
  const DanbooruCommentHeader({
    super.key,
    required this.comment,
  });

  final CommentData comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentHeader(
      authorName: comment.authorName,
      authorTitleColor: Color(getUserHexColor(comment.authorLevel)),
      createdAt: comment.createdAt,
      onTap: () => goToUserDetailsPage(
        ref,
        context,
        uid: comment.authorId,
      ),
    );
  }
}
