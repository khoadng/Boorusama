// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/functional.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';
import 'post_votes_provider.dart';

class PostVotesNotifier extends Notifier<IMap<int, PostVote?>> {
  @override
  IMap<int, PostVote?> build() {
    ref.watch(currentBooruConfigProvider);

    return <int, PostVote?>{}.lock;
  }

  PostVoteRepository get repo => ref.read(danbooruPostVoteRepoProvider);

  void _vote(PostVote? postVote) {
    if (postVote == null) return;

    state = state.add(postVote.postId, postVote);
  }

  Future<void> upvote(
    int postId, {
    bool localOnly = false,
  }) async {
    if (localOnly) {
      _vote(PostVote.local(postId: postId, score: 1));
      return;
    }

    final postVote = await repo.upvote(postId);
    _vote(postVote);
  }

  Future<void> downvote(
    int postId, {
    bool localOnly = false,
  }) async {
    if (localOnly) {
      _vote(PostVote.local(postId: postId, score: -1));
      return;
    }

    final postVote = await repo.downvote(postId);
    _vote(postVote);
  }

  void removeVote(int postId) {
    state = state.remove(postId);
  }

  Future<void> getVotes(List<int> postIds) async {
    // fetch votes for posts that are not in the cache and votes that is local
    final postIdsToFetch = postIds.where((postId) {
      if (!state.containsKey(postId)) return true;
      final postVote = state[postId];
      if (postVote == null) return false;
      return postVote.isOptimisticUpdateVote;
    }).toList();

    if (postIdsToFetch.isNotEmpty) {
      final fetchedPostVotes = await repo.getPostVotes(postIdsToFetch);
      final voteMap = {
        for (var postVote in fetchedPostVotes) postVote.postId: postVote,
      };

      state = state.addMap({
        for (var id in postIds) id: voteMap[id],
      });
    }
  }
}
