// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/boorus.dart';

class PostVotesNotifier extends Notifier<Map<int, PostVote?>> {
  @override
  Map<int, PostVote?> build() {
    ref.watch(currentBooruConfigProvider);

    return {};
  }

  PostVoteRepository get repo => ref.read(danbooruPostVoteRepoProvider);

  void _vote(PostVote? postVote) {
    if (postVote == null) return;

    state = {
      ...state,
      postVote.postId: postVote,
    };
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
    final votes = {...state}..remove(postId);
    state = {
      ...votes,
    };
  }

  Future<void> getVotes(List<int> postIds) async {
    // fetch votes for posts that are not in the cache and votes that is local
    final postIdsToFetch = postIds.where((postId) {
      final postVote = state[postId];
      return postVote == null || postVote.isOptimisticUpdateVote;
    }).toList();

    if (postIdsToFetch.isNotEmpty) {
      final fetchedPostVotes = await repo.getPostVotes(postIdsToFetch);

      state = {
        ...state,
        for (var postVote in fetchedPostVotes) postVote.postId: postVote,
      };
    }
  }
}
