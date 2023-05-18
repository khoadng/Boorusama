// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'comment_box.dart';
import 'comment_list.dart';

class CommentSection extends ConsumerWidget {
  const CommentSection({
    super.key,
    required this.commentReply,
    required this.focus,
    required this.isEditing,
    required this.postId,
    required this.comments,
  });

  final ValueNotifier<CommentData?> commentReply;
  final FocusNode focus;
  final ValueNotifier<bool> isEditing;
  final int postId;
  final List<CommentData> comments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authenticationProvider);

    return Column(
      children: [
        Expanded(
          child: CommentList(
            comments: comments,
            authenticated: auth is Authenticated,
            onEdit: (comment) {
              goToCommentUpdatePage(
                context,
                postId: postId,
                commentId: comment.id,
                commentBody: comment.body,
              );
            },
            onReply: (comment) {
              commentReply.value = comment;
              Future.delayed(
                const Duration(milliseconds: 100),
                focus.requestFocus,
              );
            },
            onDelete: (comment) => ref
                .read(danbooruCommentsProvider.notifier)
                .delete(postId: postId, comment: comment),
            onUpvote: (comment) => ref
                .read(danbooruCommentVotesProvider.notifier)
                .upvote(comment.id),
            onDownvote: (comment) => ref
                .read(danbooruCommentVotesProvider.notifier)
                .downvote(comment.id),
            onClearVote: (comment, commentVote) => ref
                .read(danbooruCommentVotesProvider.notifier)
                .unvote(commentVote),
          ),
        ),
        if (auth is Authenticated)
          CommentBox(
            focus: focus,
            commentReply: commentReply,
            postId: postId,
            isEditing: isEditing,
          ),
      ],
    );
  }
}
