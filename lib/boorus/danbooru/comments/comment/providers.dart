// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/comments/comment.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import '../../users/user/user.dart';
import 'danbooru_comment.dart';

final danbooruCommentRepoProvider =
    Provider.family<CommentRepository<DanbooruComment>, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return CommentRepositoryBuilder(
    fetch: (postId) => client
        .getComments(postId: postId, limit: 1000)
        .then((dtos) => dtos.map(commentDtoToComment).toList()),
    create: (postId, body) => client
        .postComment(postId: postId, content: body)
        .then((_) => true)
        .catchError((Object obj) => false),
    update: (commentId, body) => client
        .updateComment(commentId: commentId, content: body)
        .then((_) => true)
        .catchError((Object obj) => false),
    delete: (commentId) => client
        .deleteComment(commentId: commentId)
        .then((_) => true)
        .catchError((Object obj) => false),
  );
});

final danbooruCommentCountProvider =
    FutureProvider.autoDispose.family<int, int>((ref, postId) {
  final client = ref.watch(danbooruClientProvider(ref.watchConfigAuth));

  return client.getCommentCount(postId: postId);
});

DanbooruComment commentDtoToComment(CommentDto d) {
  return DanbooruComment(
    id: d.id ?? 0,
    score: d.score ?? 0,
    body: d.body ?? '',
    postId: d.postId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
    creator: d.creator == null
        ? DanbooruUser.placeholder()
        : userDtoToUser(d.creator!),
  );
}
