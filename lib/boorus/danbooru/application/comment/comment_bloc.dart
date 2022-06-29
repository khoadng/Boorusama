// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.authorName,
    required this.authorLevel,
    required this.body,
    required this.createdAt,
    required this.score,
    required this.isSelf,
  });

  final int id;
  final String authorName;
  final UserLevel authorLevel;
  final String body;
  final DateTime createdAt;
  final int score;
  final bool isSelf;

  @override
  List<Object?> get props =>
      [id, authorName, authorLevel, body, createdAt, score, isSelf];
}

class CommentState extends Equatable {
  const CommentState({
    required this.comments,
    required this.hiddenComments,
    required this.status,
  });

  factory CommentState.initial() => const CommentState(
        comments: [],
        hiddenComments: [],
        status: LoadStatus.initial,
      );

  CommentState copyWith({
    List<CommentData>? comments,
    List<CommentData>? hiddenComments,
    LoadStatus? status,
  }) =>
      CommentState(
        comments: comments ?? this.comments,
        hiddenComments: hiddenComments ?? this.hiddenComments,
        status: status ?? this.status,
      );

  final List<CommentData> hiddenComments;
  final List<CommentData> comments;
  final LoadStatus status;

  @override
  List<Object> get props => [comments, hiddenComments, status];
}

class CommentFetched extends CommentEvent {
  const CommentFetched({
    required this.postId,
  });

  final int postId;

  @override
  List<Object> get props => [postId];
}

class CommentSent extends CommentEvent {
  const CommentSent({
    required this.postId,
    required this.content,
  });

  final int postId;
  final String content;

  @override
  List<Object> get props => [postId, content];
}

abstract class CommentEvent extends Equatable {
  const CommentEvent();
}

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required ICommentRepository commentRepository,
    required IUserRepository userRepository,
    required IAccountRepository accountRepository,
  }) : super(CommentState.initial()) {
    on<CommentFetched>((event, emit) async {
      await tryAsync<List<Comment>>(
          action: () => commentRepository.getCommentsFromPostId(event.postId),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onSuccess: (comments) async {
            final userList = comments.map((e) => e.creatorId).toSet().toList();
            final users = await userRepository
                .getUsersByIdStringComma(userList.join(','));
            final userMap = {
              for (var i = 0; i < users.length; i += 1)
                users[i].id.value: users[i]
            };
            final account = await accountRepository.get();
            final commentData = comments
                .map((e) => CommentData(
                      id: e.id,
                      authorName: userMap[e.creatorId]?.name.value ?? 'User',
                      authorLevel:
                          userMap[e.creatorId]?.level ?? UserLevel.member,
                      body: e.body,
                      createdAt: e.createdAt,
                      score: e.score,
                      isSelf: e.creatorId == account.id,
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
  }
}
