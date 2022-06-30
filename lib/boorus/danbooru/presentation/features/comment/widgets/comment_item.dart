// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/dtext.dart';
import 'package:boorusama/core/core.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.comment,
    required this.onReply,
    this.moreBuilder,
  }) : super(key: key);
  final CommentData comment;
  final VoidCallback onReply;
  final Widget Function(BuildContext context)? moreBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentHeader(comment: comment),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _buidCommentBody(),
        ),
        if (comment.recentlyUpdated)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Last updated: ${dateTimeToStringTimeAgo(comment.updatedAt)}',
              style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                  fontSize: 12),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
                width: 30,
                child: IconButton(
                  iconSize: 16,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward),
                ),
              ),
              Text(
                comment.score.toString(),
                style: const TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 24,
                width: 30,
                child: IconButton(
                  iconSize: 16,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_downward),
                ),
              ),
              TextButton(
                onPressed: onReply,
                child: const Text('Reply'),
              ),
              if (moreBuilder != null) moreBuilder!(context),
            ],
          ),
        )
      ],
    );
  }

  Widget _buidCommentBody() {
    return Dtext.parse(
      comment.body,
      '[quote]',
      '[/quote]',
    );
  }
}

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final CommentData comment;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          DateFormat('MMM d, yyyy hh:mm a').format(comment.createdAt.toLocal()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
