// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/comment.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';

final e621CommentRepoProvider =
    Provider.family<CommentRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(e621ClientProvider(config));

  return CommentRepositoryBuilder(
    fetch: (postId, {page}) => client
        .getComments(
          postId: postId,
          page: page,
        )
        .then(
          (value) => value
              .map(
                (e) => SimpleComment(
                  id: e.id ?? 0,
                  body: e.body ?? '',
                  createdAt: e.createdAt,
                  updatedAt: e.updatedAt,
                  creatorName: e.creatorName ?? '',
                  creatorId: e.creatorId ?? 0,
                ),
              )
              .toList(),
        ),
    create: (postId, body) async => false,
    update: (commentId, body) async => false,
    delete: (commentId) async => false,
  );
});
