// Package imports:
import 'package:booru_clients/moebooru.dart';

// Project imports:
import '../types/moebooru_comment.dart';

MoebooruComment moebooruCommentDtoToMoebooruComment(CommentDto dto) {
  return MoebooruComment(
    id: dto.id ?? 0,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
    postId: dto.postId ?? 0,
    creator: dto.creator ?? '',
    creatorId: dto.creatorId ?? 0,
    body: dto.body ?? '',
  );
}
