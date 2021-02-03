// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/user_level.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/dtext.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  CommentItem({
    @required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.author.name,
                style: TextStyle(
                  color: Color(comment.author.level.hexColor),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                DateFormat('MMM d, yyyy hh:mm a').format(comment.createdAt),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Dtext.parse(
            comment.content,
            "[quote]",
            "[/quote]",
          ),
        ],
      ),
    );
  }
}
