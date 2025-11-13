// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../../../../core/posts/votes/types.dart';
import 'post_vote.dart';

sealed class RemovableVoteId {
  const RemovableVoteId();

  factory RemovableVoteId.fromUserVotes(
    VoteState? currentVoteState,
    List<DanbooruPostVote> userVotes,
  ) => switch (currentVoteState) {
    null || VoteState.unvote => const NoVoteToRemove(),
    VoteState.upvoted => _findVoteByScore(userVotes, (score) => score > 0),
    VoteState.downvoted => _findVoteByScore(userVotes, (score) => score < 0),
  };

  static RemovableVoteId _findVoteByScore(
    List<DanbooruPostVote> userVotes,
    bool Function(int) scoreMatch,
  ) {
    final matchingVote = userVotes.firstWhereOrNull(
      (vote) => scoreMatch(vote.score),
    );

    return switch (matchingVote) {
      null => const VoteNotFound(),
      final vote => FoundVoteId(vote.voteId),
    };
  }
}

final class FoundVoteId extends RemovableVoteId {
  const FoundVoteId(this.voteId);
  final PostVoteId voteId;
}

final class VoteNotFound extends RemovableVoteId {
  const VoteNotFound();
}

final class NoVoteToRemove extends RemovableVoteId {
  const NoVoteToRemove();
}
