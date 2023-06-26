// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/foundation/http/http.dart';
import 'moebooru_comment.dart';
import 'moebooru_comment_dto.dart';

MoebooruComment moebooruCommentDtoToMoebooruComment(MoebooruCommentDto dto) {
  return MoebooruComment(
    id: dto.id ?? 0,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
    postId: dto.postId ?? 0,
    creator: dto.creator ?? '',
    creatorId: dto.creatorId ?? 0,
    body: dto.body ?? '',
  );
}

List<MoebooruComment> parseMoebooruComments(HttpResponse<dynamic> response) =>
    parseResponse(
      value: response,
      converter: (item) => MoebooruCommentDto.fromJson(item),
    ).map(moebooruCommentDtoToMoebooruComment).toList();
