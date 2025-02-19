// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/comments/comment.dart';
import '../../../core/configs/config.dart';

abstract interface class GelbooruCommentRepository {
  Future<List<Comment>> getComments(int postId);
}

class GelbooruCommentRepositoryApi implements GelbooruCommentRepository {
  GelbooruCommentRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final GelbooruClient client;
  final BooruConfigAuth booruConfig;

  @override
  Future<List<Comment>> getComments(int postId) => client
      .getComments(postId: postId)
      .then((value) => value.map(gelboorucommentDtoToGelbooruComment).toList())
      .catchError((e) => <Comment>[]);
}

Comment gelboorucommentDtoToGelbooruComment(CommentDto dto) {
  final createdAt =
      DateFormat('yyyy-MM-dd HH:mm').tryParse(dto.createdAt ?? '') ??
          DateTime.now();
  return SimpleComment(
    id: int.tryParse(dto.id ?? '') ?? 0,
    body: dto.body ?? '',
    creatorName: dto.creator ?? '',
    creatorId: int.tryParse(dto.creatorId ?? '') ?? 0,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
