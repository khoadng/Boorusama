// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/widgets.dart';
import '../../../../users/details/routes.dart';
import '../../../../users/user/providers.dart';
import '../../../comment/comment.dart';

class DanbooruCommentHeader extends ConsumerWidget {
  const DanbooruCommentHeader({
    required this.comment,
    super.key,
  });

  final CommentData comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentHeader(
      authorName: comment.authorName,
      authorTitleColor:
          DanbooruUserColor.of(context).fromLevel(comment.authorLevel),
      createdAt: comment.createdAt,
      onTap: () => goToUserDetailsPage(
        ref,
        uid: comment.authorId,
      ),
    );
  }
}
