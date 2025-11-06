// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../comment/types.dart';
import '../../../votes/types.dart';
import 'comment_item.dart';

class CommentList extends StatelessWidget {
  const CommentList({
    required this.comments,
    required this.authenticated,
    required this.onEdit,
    required this.onReply,
    required this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
    required this.onClearVote,
    super.key,
  });

  final List<CommentData> comments;
  final bool authenticated;
  final void Function(CommentData comment) onReply;
  final void Function(CommentData comment) onEdit;
  final void Function(CommentData comment) onDelete;
  final void Function(CommentData comment) onUpvote;
  final void Function(CommentData comment) onDownvote;
  final void Function(CommentData comment, DanbooruCommentVote? commentVote)
  onClearVote;

  @override
  Widget build(BuildContext context) {
    return comments.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final comment = comments[index];

              return ListTile(
                title: CommentItem(
                  hasVoteSection: true,
                  onVoteChanged: (event, commentVote) => switch (event) {
                    VoteEvent.upvoted => onUpvote(comment),
                    VoteEvent.downvote => onDownvote(comment),
                    VoteEvent.voteRemoved => onClearVote(comment, commentVote),
                  },
                  comment: comment,
                  onReply: authenticated ? () => onReply(comment) : null,
                  moreBuilder: (context) => authenticated
                      ? BooruPopupMenuButton(
                          items: [
                            if (comment.isSelf)
                              BooruPopupMenuItem(
                                title: Text(context.t.comment.list.edit),
                                onTap: () => onEdit(comment),
                              ),
                            BooruPopupMenuItem(
                              title: Text(context.t.comment.list.reply),
                              onTap: () => onReply(comment),
                            ),
                            if (comment.isSelf)
                              BooruPopupMenuItem(
                                title: Text(context.t.comment.list.delete),
                                onTap: () => onDelete(comment),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
            itemCount: comments.length,
          )
        : Center(
            child: Text(context.t.comment.list.no_comments),
          );
  }
}
