// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';

class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
    Key? key,
    required this.comment,
  }) : super(key: key);

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
