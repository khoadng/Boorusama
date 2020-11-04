import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:boorusama/domain/users/user_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final User user;

  CommentItem({@required this.comment, @required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(color: Color(user.level.hexColor)),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                    DateFormat('MMM d, yyyy hh:mm a').format(comment.createdAt),
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Container(
              child: Html(
                data: comment.body,
              ),
            )
          ]),
    );
  }
}
