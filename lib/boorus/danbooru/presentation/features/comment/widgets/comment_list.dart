// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'comment_item.dart';

class CommentList extends StatelessWidget {
  const CommentList({
    Key? key,
    required this.comments,
    required this.authenticated,
    required this.onEdit,
    required this.onReply,
    required this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
    required this.onClearVote,
  }) : super(key: key);

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
    if (comments.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
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
                    ? IconButton(
                        onPressed: () => showActionListModalBottomSheet(
                          context: context,
                          children: [
                            if (comment.isSelf)
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('comment.list.edit').tr(),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onEdit(comment);
                                },
                              ),
                            ListTile(
                              leading: const Icon(Icons.reply),
                              title: const Text('comment.list.reply').tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                onReply(comment);
                              },
                            ),
                            if (comment.isSelf)
                              ListTile(
                                leading: const Icon(Icons.close),
                                title: const Text('comment.list.delete').tr(),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onDelete(comment);
                                },
                              ),
                          ],
                        ),
                        icon: const Icon(Icons.more_vert),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
          itemCount: comments.length,
        ),
      );
    } else {
      return Center(
        child: Text('comment.list.noComments'.tr()),
      );
    }
  }
}
