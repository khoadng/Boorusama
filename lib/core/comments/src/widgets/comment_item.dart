// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/html.dart';
import '../../../configs/config/types.dart';
import '../../../dtext/dtext.dart';
import '../types/comment.dart';
import 'comment_header.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    required this.comment,
    required this.config,
    super.key,
  });

  final Comment comment;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentHeader(
          authorName: comment.creatorName == null
              ? comment.creatorId?.toString() ?? 'Anon'
              : comment.creatorName!,
          authorTitleColor: Theme.of(context).colorScheme.primary,
          createdAt: comment.createdAt,
        ),
        const SizedBox(height: 4),
        AppHtml(
          data: dtext(
            comment.body,
            booruUrl: config.url,
          ),
        ),
      ],
    );
  }
}
