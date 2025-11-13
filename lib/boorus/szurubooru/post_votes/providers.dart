// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/votes/providers.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'types.dart';

class SzurubooruPostVotesNotifier
    extends FamilyNotifier<IMap<int, SzurubooruPostVote?>, BooruConfigAuth> {
  @override
  IMap<int, SzurubooruPostVote?> build(BooruConfigAuth arg) {
    return <int, SzurubooruPostVote?>{}.lock;
  }

  SzurubooruClient get client => ref.read(szurubooruClientProvider(arg));

  void _removeLocalFavorite(int postId) {
    ref.read(favoritesProvider(arg).notifier).removeLocalFavorite(postId);
  }

  Future<void> upvote(int postId, {bool localOnly = false}) async {
    final vote = localOnly
        ? SzurubooruPostVote.local(postId: postId, score: 1)
        : await client
              .upvotePost(postId: postId)
              .then(SzurubooruPostVote.fromPostDto);

    state = VotesStateHelpers.updateVote(state, vote);
  }

  Future<void> downvote(int postId, {bool localOnly = false}) async {
    if (localOnly) {
      state = VotesStateHelpers.updateVote(
        state,
        SzurubooruPostVote.local(postId: postId, score: -1),
      );
      return;
    }

    final post = await client.downvotePost(postId: postId);
    _removeLocalFavorite(postId);
    state = VotesStateHelpers.updateVote(
      state,
      SzurubooruPostVote.fromPostDto(post),
    );
  }

  void removeLocalVote(int postId) {
    state = VotesStateHelpers.removeVoteFromState(state, postId);
  }

  Future<void> removeVote(int postId) async {
    await client.unvotePost(postId: postId);
    _removeLocalFavorite(postId);
    removeLocalVote(postId);
  }

  Future<void> getVotes(List<SzurubooruPost> posts) async {
    final postIds = posts.map((post) => post.id).toList();
    final postIdsToFetch = VotesStateHelpers.filterPostIdsNeedingFetch(
      state,
      postIds,
    );

    if (postIdsToFetch.isEmpty) return;

    final fetchedVotes = posts.map(SzurubooruPostVote.fromPost).toList();
    state = VotesStateHelpers.mergeVotesIntoState(state, postIds, fetchedVotes);
  }
}

final szurubooruPostVotesProvider =
    NotifierProvider.family<
      SzurubooruPostVotesNotifier,
      IMap<int, SzurubooruPostVote?>,
      BooruConfigAuth
    >(
      SzurubooruPostVotesNotifier.new,
    );

final szurubooruPostVoteProvider = Provider.autoDispose
    .family<SzurubooruPostVote?, int>(
      (ref, postId) {
        final config = ref.watchConfigAuth;
        return ref.watch(szurubooruPostVotesProvider(config))[postId];
      },
    );
