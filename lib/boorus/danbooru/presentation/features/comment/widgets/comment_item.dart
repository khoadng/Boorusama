// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/dtext.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              comment.author.displayName,
              style: TextStyle(
                color: Color(comment.author.level.level.hexColor),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              DateFormat('MMM d, yyyy hh:mm a').format(comment.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Dtext.parse(
          comment.body,
          "[quote]",
          "[/quote]",
        ),
      ],
    );
  }
}
