// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_comment_vote.dart';

DanbooruCommentVote commentVoteDtoToCommentVote(CommentVoteDto d) {
  return DanbooruCommentVote(
    id: d.id ?? 0,
    commentId: d.commentId ?? 0,
    userId: d.userId ?? 0,
    score: d.score ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    isDeleted: d.isDeleted ?? false,
  );
}
