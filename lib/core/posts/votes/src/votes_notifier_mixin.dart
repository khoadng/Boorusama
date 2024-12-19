// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../post/post.dart';
import 'post_vote.dart';

mixin VotesNotifierMixin<T extends PostVote, P extends Post> {
  Future<T?> Function(int postId) get upvoter;
  Future<T?> Function(int postId) get downvoter;
  Future<bool> Function(int postId) get voteRemover;
  Future<List<T>> Function(List<P> posts) get votesFetcher;
  T Function(int postId, int score) get localVoteBuilder;

  IMap<int, T?> get votes;

  void Function(IMap<int, T?> data) get updateVotes;

  void _vote(T? postVote) {
    if (postVote == null) return;

    final newData = votes.add(postVote.postId, postVote);
    updateVotes(newData);
  }

  Future<void> upvote(
    int postId, {
    bool localOnly = false,
  }) async {
    if (localOnly) {
      _vote(localVoteBuilder(postId, 1));
      return;
    }

    final postVote = await upvoter(postId);

    _vote(postVote);
  }

  Future<void> downvote(
    int postId, {
    bool localOnly = false,
  }) async {
    if (localOnly) {
      _vote(localVoteBuilder(postId, -1));
      return;
    }

    final postVote = await downvoter(postId);

    _vote(postVote);
  }

  void removeLocalVote(int postId) {
    final newData = votes.remove(postId);
    updateVotes(newData);
  }

  Future<void> removeVote(int postId) async {
    final success = await voteRemover(postId);
    if (success) {
      removeLocalVote(postId);
    }
  }

  Future<void> getVotes(List<P> posts) async {
    final postIds = posts.map((post) => post.id).toList();
    // fetch votes for posts that are not in the cache and votes that is local
    final postIdsToFetch = postIds.where((postId) {
      if (!votes.containsKey(postId)) return true;
      final postVote = votes[postId];
      if (postVote == null) return false;
      return postVote.isOptimisticUpdateVote;
    }).toList();

    if (postIdsToFetch.isNotEmpty) {
      final fetchedPostVotes = await votesFetcher(posts);
      final voteMap = {
        for (final postVote in fetchedPostVotes) postVote.postId: postVote,
      };

      final newData = votes.addMap({for (final id in postIds) id: voteMap[id]});

      updateVotes(newData);
    }
  }
}
