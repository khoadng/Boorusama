// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/votes.dart';
import '../../users/user/providers.dart';
import '../post/danbooru_post.dart';
import 'post_vote.dart';
import 'post_vote_repository_api.dart';
import 'providers.dart';

final danbooruPostVotesProvider = NotifierProvider.family<PostVotesNotifier,
    IMap<int, DanbooruPostVote?>, BooruConfigAuth>(
  PostVotesNotifier.new,
  dependencies: [
    danbooruPostVoteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVoteProvider =
    Provider.autoDispose.family<DanbooruPostVote?, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(danbooruPostVotesProvider(config))[postId];
  },
);

class PostVotesNotifier
    extends FamilyNotifier<IMap<int, DanbooruPostVote?>, BooruConfigAuth>
    with VotesNotifierMixin<DanbooruPostVote, DanbooruPost> {
  @override
  IMap<int, DanbooruPostVote?> build(BooruConfigAuth arg) {
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

            return repo.getPostVotesFromUser(postIds, user.id);
          };
}
