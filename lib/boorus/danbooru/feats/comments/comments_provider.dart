// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruCommentRepoProvider =
    Provider.family<CommentRepository<DanbooruComment>, BooruConfig>(
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

final danbooruCommentsProvider = NotifierProvider.family<CommentsNotifier,
    Map<int, List<CommentData>?>, BooruConfig>(
  CommentsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruCommentProvider =
    Provider.autoDispose.family<List<CommentData>?, int>((ref, postId) {
  final config = ref.watchConfig;
  return ref.watch(danbooruCommentsProvider(config))[postId];
});

final danbooruCommentCountProvider =
    FutureProvider.autoDispose.family<int, int>((ref, postId) {
  final client = ref.watch(danbooruClientProvider(ref.watchConfig));

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
    creator: d.creator == null ? User.placeholder() : userDtoToUser(d.creator!),
  );
}
