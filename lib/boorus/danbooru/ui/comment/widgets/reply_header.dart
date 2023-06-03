// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/i18n.dart';

class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
    super.key,
    required this.comment,
  });

  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        children: [
          Text(
            '${'comment.list.reply_to'.tr()} ',
            softWrap: true,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            '@${comment.authorName}',
            softWrap: true,
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
