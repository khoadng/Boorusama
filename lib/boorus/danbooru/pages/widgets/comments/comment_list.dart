// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
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
                      ? PopupMenuButton(
                          icon: const Icon(
                            Symbols.more_vert,
                            weight: 400,
                          ),
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
                                  visualDensity: const ShrinkVisualDensity(),
                                  dense: true,
                                  leading: const Icon(
                                    Symbols.edit,
                                    fill: 1,
                                  ),
                                  title: const Text('comment.list.edit').tr(),
                                ),
                              ),
                            PopupMenuItem(
                              value: 'reply',
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                visualDensity: const ShrinkVisualDensity(),
                                dense: true,
                                leading: const Icon(Symbols.reply),
                                title: const Text('comment.list.reply').tr(),
                              ),
                            ),
                            if (comment.isSelf)
                              PopupMenuItem(
                                value: 'delete',
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  visualDensity: const ShrinkVisualDensity(),
                                  dense: true,
                                  leading: const Icon(Symbols.close),
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
