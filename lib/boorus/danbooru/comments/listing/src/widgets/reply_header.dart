// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../users/user/providers.dart';
import '../../../comment/comment.dart';

class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
    required this.comment,
    super.key,
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
            '${context.t.comment.list.reply_to} ',
            softWrap: true,
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
          Text(
            '@${comment.authorName}',
            softWrap: true,
            style: TextStyle(
              color: DanbooruUserColor.of(
                context,
              ).fromLevel(comment.authorLevel),
            ),
          ),
        ],
      ),
    );
  }
}
