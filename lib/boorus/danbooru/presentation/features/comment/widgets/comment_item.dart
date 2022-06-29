// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/dtext.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.comment,
  }) : super(key: key);
  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              comment.authorName.replaceAll('_', ' '),
              style: TextStyle(
                color: Color(comment.authorLevel.hexColor),
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
          '[quote]',
          '[/quote]',
        ),
      ],
    );
  }
}
