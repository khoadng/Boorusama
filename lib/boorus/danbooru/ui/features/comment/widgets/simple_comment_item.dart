// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'comment_header.dart';
import 'dtext.dart';

class SimpleCommentItem extends StatelessWidget {
  const SimpleCommentItem({
    Key? key,
    required this.authorName,
    required this.content,
    required this.createdAt,
  }) : super(key: key);
  final String authorName;
  final String content;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: authorName,
          createdAt: createdAt,
        ),
        Dtext.parse(
          content,
          '[quote]',
          '[/quote]',
        ),
      ],
    );
  }
}
