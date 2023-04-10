// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
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
  final void Function(CommentData comment) onClearVote;

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
                  onVoteChanged: (event) {
                    if (event == VoteEvent.upvoted) {
                      onUpvote(comment);
                    } else if (event == VoteEvent.downvote) {
                      onDownvote(comment);
                    } else if (event == VoteEvent.voteRemoved) {
                      if (comment.hasVote) {
                        onClearVote(comment);
                      }
                    } else {
                      //TODO: unknown vote event
                    }
                  },
                  comment: comment,
                  onReply: () => onReply(comment),
                  moreBuilder: (context) => authenticated
                      ? PopupMenuButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 150),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit(comment);
                            } else if (value == 'reply') {
                              onReply(comment);
                            } else if (value == 'delete') {
                              onDelete(comment);
                            }
                          },
                          itemBuilder: (context) => [
                            if (comment.isSelf)
                              PopupMenuItem(
                                value: 'edit',
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  dense: true,
                                  leading: const Icon(Icons.edit),
                                  title: const Text('comment.list.edit').tr(),
                                ),
                              ),
                            PopupMenuItem(
                              value: 'reply',
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                dense: true,
                                leading: const Icon(Icons.reply),
                                title: const Text('comment.list.reply').tr(),
                              ),
                            ),
                            if (comment.isSelf)
                              PopupMenuItem(
                                value: 'delete',
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  dense: true,
                                  leading: const Icon(Icons.close),
                                  title: const Text('comment.list.delete').tr(),
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
            itemCount: comments.length,
          )
        : Center(child: Text('comment.list.noComments'.tr()));
  }
}
