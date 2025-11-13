// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'post_vote.dart';

class VotesStateHelpers {
  static IMap<int, T?> updateVote<T extends PostVote>(
    IMap<int, T?> votes,
    T? vote,
  ) {
    if (vote == null) return votes;
    return votes.add(vote.postId, vote);
  }

  static IMap<int, T?> removeVoteFromState<T extends PostVote>(
    IMap<int, T?> votes,
    int postId,
  ) {
    return votes.remove(postId);
  }

  static List<int> filterPostIdsNeedingFetch<T extends PostVote>(
    IMap<int, T?> votes,
    List<int> postIds,
  ) {
    return postIds.where((postId) {
      if (!votes.containsKey(postId)) return true;
      final postVote = votes[postId];
      if (postVote == null) return false;
      return postVote.isOptimisticUpdateVote;
    }).toList();
  }

  static IMap<int, T?> mergeVotesIntoState<T extends PostVote>(
    IMap<int, T?> currentVotes,
    List<int> postIds,
    List<T> fetchedVotes,
  ) {
    final voteMap = {
      for (final vote in fetchedVotes) vote.postId: vote,
    };
    return currentVotes.addMap({for (final id in postIds) id: voteMap[id]});
  }
}
