import 'package:boorusama/application/comment/comment.dart';
import 'package:boorusama/application/comment/user_level.dart';
import 'package:boorusama/presentation/services/dtext/dtext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
