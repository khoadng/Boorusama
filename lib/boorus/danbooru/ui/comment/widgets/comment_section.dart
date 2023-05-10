// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
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
  });

  final ValueNotifier<CommentData?> commentReply;
  final FocusNode focus;
  final ValueNotifier<bool> isEditing;
  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authenticationProvider);
    final comments = context.select((CommentBloc bloc) => bloc.state.comments);

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
            onDelete: (comment) =>
                context.read<CommentBloc>().add(CommentDeleted(
                      commentId: comment.id,
                      postId: postId,
                    )),
            onUpvote: (comment) => context
                .read<CommentBloc>()
                .add(CommentUpvoted(commentId: comment.id)),
            onDownvote: (comment) => context
                .read<CommentBloc>()
                .add(CommentDownvoted(commentId: comment.id)),
            onClearVote: (comment) =>
                context.read<CommentBloc>().add(CommentVoteRemoved(
                      commentId: comment.id,
                      commentVoteId: comment.voteId!,
                      voteState: comment.voteState,
                    )),
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
