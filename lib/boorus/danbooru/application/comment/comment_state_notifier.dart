// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/comment/user.dart';
import 'package:boorusama/boorus/danbooru/application/comment/user_level.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/i_comment_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';

import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart'
    as domain;

part 'comment_state.dart';
part 'comment_state_notifier.freezed.dart';

class CommentStateNotifier extends StateNotifier<CommentState> {
  final ICommentRepository _commentRepository;
  final IUserRepository _userRepository;

  CommentStateNotifier(ProviderReference ref)
      : _commentRepository = ref.read(commentProvider),
        _userRepository = ref.watch(userProvider),
        super(CommentState.empty());

  void getComments(int postId) async {
    state = CommentState.loading();
    final dtos = await _commentRepository.getCommentsFromPostId(postId);
    final domainComments = <domain.Comment>[];
    dtos.forEach((dto) => domainComments.add(dto.toEntity()));

    final userList = <String>[];
    domainComments.forEach((comment) {
      if (!userList.contains(comment.creatorId.toString())) {
        userList.add(comment.creatorId.toString());
      }
    });

    final users =
        await _userRepository.getUsersByIdStringComma(userList.join(","));

    final comments = <Comment>[];

    for (var comment in domainComments..sort((a, b) => a.id.compareTo(b.id))) {
      final author = users.where((user) => user.id == comment.creatorId).first;
      comments.add(Comment(
        id: comment.id,
        author: User(
            level: UserLevel(author.level).level, name: author.displayName),
        content: comment.body,
        isDeleted: comment.isDeleted,
        createdAt: comment.createdAt,
      ));
    }

    state = CommentState.fetched(comments: comments);
  }

  void addComment(int postId, String content) async {
    state = const CommentState.loading();
    final success = await _commentRepository.postComment(postId, content);

    if (!success) {
      state = CommentState.error();
    }

    state = CommentState.addedSuccess();
    // getComments(postId);
  }

  void updateComment(int commentId, int postId, String content) async {
    state = const CommentState.loading();
    final success = await _commentRepository.updateComment(commentId, content);

    if (!success) {
      state = CommentState.error();
    }

    state = CommentState.updatedSuccess();
    // getComments(postId);
  }
}
