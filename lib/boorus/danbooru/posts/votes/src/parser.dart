// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import 'post_vote.dart';

DanbooruPostVote postVoteDtoToPostVote(PostVoteDto d) {
  return DanbooruPostVote(
    voteId: d.id ?? const PostVoteId.fromInt(0),
    postId: d.postId ?? 0,
    userId: d.userId ?? 0,
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    score: d.score ?? 0,
    isDeleted: d.isDeleted ?? false,
  );
}
