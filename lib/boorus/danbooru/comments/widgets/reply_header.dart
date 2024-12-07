// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/comments/comments.dart';
import 'package:boorusama/core/users/colors.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';

class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
    super.key,
    required this.comment,
  });

  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
        top: 4,
      ),
      child: Wrap(
        children: [
          Text(
            '${'comment.list.reply_to'.tr()} ',
            softWrap: true,
            style: TextStyle(
              color: context.colorScheme.hintColor,
            ),
          ),
          Text(
            '@${comment.authorName}',
            softWrap: true,
            style: TextStyle(
              color: comment.authorLevel.toColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
