// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'comment.dart';
import 'comment_repository.dart';

class CommentRepositoryApi implements CommentRepository {
  CommentRepositoryApi(
    DanbooruClient client,
  ) : _client = client;

  final DanbooruClient _client;

  @override
  Future<List<Comment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  }) =>
      _client
          .getComments(
            postId: postId,
            limit: 1000,
            cancelToken: cancelToken,
          )
          .then((dtos) => dtos.map(commentDtoToComment).toList());

  @override
  Future<bool> postComment(int postId, String content) => _client
      .postComment(
        postId: postId,
        content: content,
      )
      .then((_) => true)
      .catchError((Object obj) => false);

  @override
  Future<bool> updateComment(int commentId, String content) => _client
      .updateComment(
        commentId: commentId,
        content: content,
      )
      .then((_) => true)
      .catchError((Object obj) => false);

  @override
  Future<bool> deleteComment(int commentId) => _client
      .deleteComment(
        commentId: commentId,
      )
      .then((_) => true)
      .catchError((Object obj) => false);
}

Comment commentDtoToComment(CommentDto d) {
  return Comment(
    id: d.id ?? 0,
    score: d.score ?? 0,
    body: d.body ?? '',
    postId: d.postId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
    creator: d.creator == null ? User.placeholder() : userDtoToUser(d.creator!),
  );
}
