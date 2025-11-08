// Package imports:
import 'package:booru_clients/shimmie2.dart';

// Project imports:
import '../../../core/comments/types.dart';

Comment? commentDtoToComment(CommentDto dto) {
  return switch (dto) {
    CommentDto(
      id: final id?,
    ) =>
      SimpleComment(
        id: id,
        body: dto.comment ?? '',
        createdAt: dto.posted,
        updatedAt: dto.posted,
        creatorName: dto.ownerName,
        creatorId: dto.ownerId,
      ),
    _ => null,
  };
}
