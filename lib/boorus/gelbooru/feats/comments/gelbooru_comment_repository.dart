// Dart imports:
import 'dart:async';

// Package imports:
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/gelbooru_comment.dart';
import 'package:boorusama/dart.dart';
import 'gelbooru_comment_dto.dart';

abstract interface class GelbooruCommentRepository {
  Future<List<GelbooruComment>> getComments(int postId);
}

class GelbooruCommentRepositoryApi implements GelbooruCommentRepository {
  GelbooruCommentRepositoryApi({
    required this.api,
    required this.booruConfig,
  });

  final GelbooruApi api;
  final BooruConfig booruConfig;

  @override
  Future<List<GelbooruComment>> getComments(int postId) => api
      .getComments(
        booruConfig.login,
        booruConfig.apiKey,
        'dapi',
        'comment',
        'index',
        postId,
      )
      .then(_parseCommentDtos)
      .then((value) => value.map(gelboorucommentDtoToGelbooruComment).toList())
      .catchError((e) => <GelbooruComment>[]);
}

FutureOr<List<GelbooruCommentDto>> _parseCommentDtos(value) {
  final dtos = <GelbooruCommentDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final comments = xmlDocument.findAllElements('comment');
  for (final item in comments) {
    dtos.add(GelbooruCommentDto.fromXml(item));
  }
  return dtos;
}

GelbooruComment gelboorucommentDtoToGelbooruComment(GelbooruCommentDto dto) {
  return GelbooruComment(
    id: int.tryParse(dto.id ?? '') ?? 0,
    postId: int.tryParse(dto.postId ?? '') ?? 0,
    body: dto.body ?? '',
    creator: dto.creator ?? '',
    creatorId: int.tryParse(dto.creatorId ?? '') ?? 0,
    createdAt: DateFormat('yyyy-MM-dd HH:mm').tryParse(dto.createdAt ?? '') ??
        DateTime.now(),
  );
}
