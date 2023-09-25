// Dart imports:
import 'dart:async';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/comments/comments.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/time.dart';

abstract interface class GelbooruCommentRepository {
  Future<List<Comment>> getComments(int postId);
}

class GelbooruCommentRepositoryApi implements GelbooruCommentRepository {
  GelbooruCommentRepositoryApi({
    required this.client,
    required this.booruConfig,
  });

  final GelbooruClient client;
  final BooruConfig booruConfig;

  @override
  Future<List<Comment>> getComments(int postId) => client
      .getComments(postId: postId)
      .then((value) => value.map(gelboorucommentDtoToGelbooruComment).toList())
      .catchError((e) => <Comment>[]);
}

Comment gelboorucommentDtoToGelbooruComment(CommentDto dto) {
  return SimpleComment(
    id: int.tryParse(dto.id ?? '') ?? 0,
    body: dto.body ?? '',
    creatorName: dto.creator ?? '',
    creatorId: int.tryParse(dto.creatorId ?? '') ?? 0,
    createdAt: DateFormat('yyyy-MM-dd HH:mm').tryParse(dto.createdAt ?? '') ??
        DateTime.now(),
  );
}
