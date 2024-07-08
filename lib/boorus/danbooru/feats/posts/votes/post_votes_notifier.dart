// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/functional.dart';
import '../../users/users.dart';
import 'danbooru_post_vote.dart';
import 'post_vote_repository.dart';
import 'post_votes_provider.dart';

class PostVotesNotifier
    extends FamilyNotifier<IMap<int, DanbooruPostVote?>, BooruConfig> {
  @override
  IMap<int, DanbooruPostVote?> build(BooruConfig arg) {
    return <int, DanbooruPostVote?>{}.lock;
  }

  PostVoteRepository get repo => ref.read(danbooruPostVoteRepoProvider(arg));

  void _vote(DanbooruPostVote? postVote) {
    if (postVote == null) return;

    state = state.add(postVote.postId, postVote);
  }

  Future<void> upvote(
    int postId, {
    bool localOnly = false,
  }) async {
    if (localOnly) {
      _vote(DanbooruPostVote.local(postId: postId, score: 1));
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
      _vote(DanbooruPostVote.local(postId: postId, score: -1));
      return;
    }

    final postVote = await repo.downvote(postId);
    _vote(postVote);
  }

  void removeLocalVote(int postId) {
    state = state.remove(postId);
  }

  Future<void> removeVote(int postId) async {
    final success = await repo.removeVote(postId);
    if (success) {
      removeLocalVote(postId);
    }
  }

  Future<void> getVotes(List<int> postIds) async {
    // fetch votes for posts that are not in the cache and votes that is local
    final postIdsToFetch = postIds.where((postId) {
      if (!state.containsKey(postId)) return true;
      final postVote = state[postId];
      if (postVote == null) return false;
      return postVote.isOptimisticUpdateVote;
    }).toList();

    final user = await ref.read(danbooruCurrentUserProvider(arg).future);

    if (postIdsToFetch.isNotEmpty && user != null) {
      final fetchedPostVotes = await repo.getPostVotes(postIdsToFetch, user.id);
      final voteMap = {
        for (var postVote in fetchedPostVotes) postVote.postId: postVote,
      };

      state = state.addMap({
        for (var id in postIds) id: voteMap[id],
      });
    }
  }
}
