// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required ICommentRepository commentRepository,
    required IUserRepository userRepository,
    required IAccountRepository accountRepository,
    required CommentVoteRepository commentVoteRepository,
  }) : super(CommentState.initial()) {
    on<CommentFetched>((event, emit) async {
      await tryAsync<List<Comment>>(
          action: () => commentRepository.getCommentsFromPostId(event.postId),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onSuccess: (comments) async {
            final commentList = comments.where(notDeleted);
            final userList =
                commentList.map((e) => e.creatorId).toSet().toList();
            final users = await userRepository
                .getUsersByIdStringComma(userList.join(','));
            final userMap = {
              for (var i = 0; i < users.length; i += 1)
                users[i].id.value: users[i]
            };
            final votes = await commentVoteRepository
                .getCommentVotes(commentList.map((e) => e.id).toList());

            final account = await accountRepository.get();
            final commentData = commentList
                .map((e) => commentDataFrom(
                      e,
                      userMap[e.creatorId],
                      account,
                      votes,
                    ))
                .toList();

            emit(state.copyWith(
              comments: commentData..sort((a, b) => a.id.compareTo(b.id)),
              hiddenComments: [],
              status: LoadStatus.success,
            ));
          });
    });

    on<CommentSent>((event, emit) async {
      await tryAsync<bool>(
        action: () =>
            commentRepository.postComment(event.postId, event.content),
        onSuccess: (success) async {
          add(CommentFetched(postId: event.postId));
        },
      );
    });

    on<CommentUpdated>((event, emit) async {
      await tryAsync<bool>(
        action: () =>
            commentRepository.updateComment(event.commentId, event.content),
        onSuccess: (success) async {
          add(CommentFetched(postId: event.postId));
        },
      );
    });

    on<CommentDeleted>((event, emit) async {
      await tryAsync<bool>(
        action: () => commentRepository.deleteComment(event.commentId),
        onSuccess: (success) async {
          add(CommentFetched(postId: event.postId));
        },
      );
    });
  }
}
