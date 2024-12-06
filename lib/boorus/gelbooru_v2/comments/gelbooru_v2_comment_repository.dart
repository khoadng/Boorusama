// Dart imports:
import 'dart:async';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/clients/gelbooru/gelbooru_v2_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs.dart';

abstract interface class GelbooruV2CommentRepository {
  Future<List<Comment>> getComments(int postId);
}

class GelbooruV2CommentRepositoryApi implements GelbooruV2CommentRepository {
  GelbooruV2CommentRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final GelbooruV2Client client;
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
