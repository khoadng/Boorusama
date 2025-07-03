// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config.dart';
import '../client_provider.dart';

final gelbooruCommentRepoProvider =
    Provider.family<CommentRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(gelbooruClientProvider(config));

  return CommentRepositoryBuilder(
    fetch: (postId, {page}) => client
        .getCommentsFromPostId(postId: postId, page: page)
        .then(
          (value) => value.map(gelboorucommentDtoToGelbooruComment).toList(),
        )
        .catchError((e) => <Comment>[]),
    create: (postId, body) async => false,
    update: (commentId, body) async => false,
    delete: (commentId) async => false,
  );
});

Comment gelboorucommentDtoToGelbooruComment(CommentDto dto) {
  final createdAt =
      DateFormat('yyyy-MM-dd HH:mm').tryParse(dto.createdAt ?? '');

  return SimpleComment(
    id: int.tryParse(dto.id ?? '') ?? 0,
    body: dto.body ?? '',
    creatorName: dto.creator ?? '',
    creatorId: int.tryParse(dto.creatorId ?? '') ?? 0,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
