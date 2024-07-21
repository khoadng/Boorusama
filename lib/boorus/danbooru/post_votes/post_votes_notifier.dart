// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';
import '../posts/posts.dart';
import '../users/users.dart';
import 'danbooru_post_vote.dart';
import 'post_vote_repository.dart';
import 'post_votes_provider.dart';

class PostVotesNotifier
    extends FamilyNotifier<IMap<int, DanbooruPostVote?>, BooruConfig>
    with VotesNotifierMixin<DanbooruPostVote, DanbooruPost> {
  @override
  IMap<int, DanbooruPostVote?> build(BooruConfig arg) {
    return <int, DanbooruPostVote?>{}.lock;
  }

  PostVoteRepository get repo => ref.read(danbooruPostVoteRepoProvider(arg));

  @override
  Future<DanbooruPostVote?> Function(int postId) get upvoter => repo.upvote;

  @override
  Future<bool> Function(int postId) get voteRemover => repo.removeVote;

  @override
  Future<DanbooruPostVote?> Function(int postId) get downvoter => repo.downvote;

  @override
  DanbooruPostVote Function(int postId, int score) get localVoteBuilder =>
      (postId, score) => DanbooruPostVote.local(postId: postId, score: score);

  @override
  void Function(IMap<int, DanbooruPostVote?> data) get updateVotes =>
      (data) => state = data;

  @override
  IMap<int, DanbooruPostVote?> get votes => state;

  @override
  Future<List<DanbooruPostVote>> Function(List<DanbooruPost> posts)
      get votesFetcher => (posts) async {
            final user =
                await ref.read(danbooruCurrentUserProvider(arg).future);
            if (user == null) return [];

            final postIds = posts.map((e) => e.id).toList();

            return repo.getPostVotes(postIds, user.id);
          };
}
