// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'comment_item.dart';

class CommentList extends StatelessWidget {
  const CommentList({
    super.key,
    required this.comments,
    required this.authenticated,
    required this.onEdit,
    required this.onReply,
    required this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
    required this.onClearVote,
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
                  hasVoteSection: authenticated,
                  onVoteChanged: (event, commentVote) {
                    if (event == VoteEvent.upvoted) {
                      onUpvote(comment);
                    } else if (event == VoteEvent.downvote) {
                      onDownvote(comment);
                    } else if (event == VoteEvent.voteRemoved) {
                      onClearVote(comment, commentVote);
                    } else {
                      //TODO: unknown vote event
                    }
                  },
                  comment: comment,
                  onReply: () => onReply(comment),
                  moreBuilder: (context) => authenticated
                      ? BooruPopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit(comment);
                            } else if (value == 'reply') {
                              onReply(comment);
                            } else if (value == 'delete') {
                              onDelete(comment);
                            }
                          },
                          itemBuilder: {
                              'edit': const Text('comment.list.edit').tr(),
                              'reply': const Text('comment.list.reply').tr(),
                              if (comment.isSelf)
                                'delete':
                                    const Text('comment.list.delete').tr(),
                            })
                      : const SizedBox.shrink(),
                ),
              );
            },
            itemCount: comments.length,
          )
        : Center(child: Text('comment.list.noComments'.tr()));
  }
}
