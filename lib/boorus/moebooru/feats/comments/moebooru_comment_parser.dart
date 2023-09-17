// Project imports:
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'moebooru_comment.dart';

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
