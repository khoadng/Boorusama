// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/comments/comment_header.dart';
import '../../../users/level/colors.dart';
import '../comment_data.dart';

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
        context,
        uid: comment.authorId,
      ),
    );
  }
}
