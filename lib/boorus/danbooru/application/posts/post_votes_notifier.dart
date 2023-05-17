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

  Future<void> upvote(int postId) async {
    final postVote = await repo.upvote(postId);
    if (postVote == null) return;

    state = {
      ...state,
      postId: postVote,
    };
  }

  Future<void> downvote(int postId) async {
    final postVote = await repo.downvote(postId);
    if (postVote == null) return;

    state = {
      ...state,
      postId: postVote,
    };
  }

  Future<void> getVotes(List<int> postIds) async {
    final postIdsToFetch =
        postIds.where((postId) => !state.containsKey(postId)).toList();

    if (postIdsToFetch.isNotEmpty) {
      final fetchedPostVotes = await repo.getPostVotes(postIdsToFetch);

      state = {
        ...state,
        for (var postVote in fetchedPostVotes) postVote.postId: postVote,
      };
    }
  }
}
