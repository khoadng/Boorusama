// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/comments/widgets.dart';
import '../../../comment/types.dart';
import '../../../votes/types.dart';
import 'comment_item.dart' as danbooru;

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
    this.scrollController,
  });

  final List<CommentData> comments;
  final bool authenticated;
  final ScrollController? scrollController;
  final void Function(CommentData comment) onReply;
  final void Function(CommentData comment) onEdit;
  final void Function(CommentData comment) onDelete;
  final void Function(CommentData comment) onUpvote;
  final void Function(CommentData comment) onDownvote;
  final void Function(CommentData comment, DanbooruCommentVote? commentVote)
  onClearVote;

  @override
  Widget build(BuildContext context) {
    return CommentListView<CommentData>(
      scrollController: scrollController,
      comments: comments,
      authenticated: authenticated,
      isSelf: (comment) => comment.isSelf,
      onEdit: onEdit,
      onReply: onReply,
      onDelete: onDelete,
      itemBuilder: (context, comment, onReply, moreBuilder) =>
          danbooru.CommentItem(
            hasVoteSection: true,
            onVoteChanged: (event, commentVote) => switch (event) {
              VoteEvent.upvoted => onUpvote(comment),
              VoteEvent.downvote => onDownvote(comment),
              VoteEvent.voteRemoved => onClearVote(comment, commentVote),
            },
            comment: comment,
            onReply: onReply,
            moreBuilder: moreBuilder,
          ),
    );
  }
}
