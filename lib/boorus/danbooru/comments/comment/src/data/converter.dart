// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../users/user/types.dart';
import '../types/danbooru_comment.dart';

DanbooruComment commentDtoToComment(CommentDto d) {
  return DanbooruComment(
    id: d.id ?? 0,
    score: d.score ?? 0,
    body: d.body ?? '',
    postId: d.postId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
    creator: d.creator == null
        ? DanbooruUser.placeholder()
        : userDtoToUser(d.creator!),
  );
}
