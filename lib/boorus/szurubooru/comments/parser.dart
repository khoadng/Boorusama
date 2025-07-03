// Package imports:
import 'package:booru_clients/szurubooru.dart';

// Project imports:
import '../../../core/comments/types.dart';

SimpleComment parseSzurubooruComment(CommentDto e) {
  return SimpleComment(
    id: e.id ?? 0,
    body: e.text ?? '',
    createdAt: e.creationTime != null ? DateTime.parse(e.creationTime!) : null,
    updatedAt: e.lastEditTime != null ? DateTime.parse(e.lastEditTime!) : null,
    creatorName: e.user?.name ?? '',
  );
}
