// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/current.dart';
import '../../../core/configs/ref.dart';
import '../../../core/favorites/providers.dart';
import '../../../core/posts/votes/providers.dart';
import '../providers.dart';
import '../szurubooru_post.dart';
import 'post_votes.dart';

class SzurubooruPostVotesNotifier
    extends FamilyNotifier<IMap<int, SzurubooruPostVote?>, BooruConfigAuth>
    with VotesNotifierMixin<SzurubooruPostVote, SzurubooruPost> {
  @override
  IMap<int, SzurubooruPostVote?> build(BooruConfigAuth arg) {
    return <int, SzurubooruPostVote?>{}.lock;
  }

  void _removeLocalFavorite(int postId) {
    ref.read(favoritesProvider(arg).notifier).removeLocalFavorite(postId);
  }

  SzurubooruClient get client => ref.read(szurubooruClientProvider(arg));

  @override
  Future<SzurubooruPostVote?> Function(int postId) get upvoter => (postId) =>
      client.upvotePost(postId: postId).then(SzurubooruPostVote.fromPostDto);

  @override
  Future<bool> Function(int postId) get voteRemover => (postId) async {
        await client.unvotePost(postId: postId);

        _removeLocalFavorite(postId);

        return true;
      };

  @override
  Future<SzurubooruPostVote?> Function(int postId) get downvoter =>
      (postId) async {
        final post = await client.downvotePost(postId: postId);

        _removeLocalFavorite(postId);

        return SzurubooruPostVote.fromPostDto(post);
      };

  @override
  SzurubooruPostVote Function(int postId, int score) get localVoteBuilder =>
      (postId, score) => SzurubooruPostVote.local(postId: postId, score: score);

  @override
  void Function(IMap<int, SzurubooruPostVote?> data) get updateVotes =>
      (data) => state = data;

  @override
  IMap<int, SzurubooruPostVote?> get votes => state;

  @override
  Future<List<SzurubooruPostVote>> Function(List<SzurubooruPost> posts)
      get votesFetcher => (posts) async {
            final votes = posts.map(SzurubooruPostVote.fromPost).toList();

            return votes;
          };
}

final szurubooruPostVotesProvider = NotifierProvider.family<
    SzurubooruPostVotesNotifier,
    IMap<int, SzurubooruPostVote?>,
    BooruConfigAuth>(
  SzurubooruPostVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final szurubooruPostVoteProvider =
    Provider.autoDispose.family<SzurubooruPostVote?, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(szurubooruPostVotesProvider(config))[postId];
  },
);
