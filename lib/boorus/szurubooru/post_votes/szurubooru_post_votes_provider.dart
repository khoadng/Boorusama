// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';
import '../favorites/favorites.dart';
import '../providers.dart';
import '../szurubooru_post.dart';
import 'post_votes.dart';

class SzurubooruPostVotesNotifier
    extends FamilyNotifier<IMap<int, SzurubooruPostVote?>, BooruConfig>
    with VotesNotifierMixin<SzurubooruPostVote, SzurubooruPost> {
  @override
  IMap<int, SzurubooruPostVote?> build(BooruConfig arg) {
    return <int, SzurubooruPostVote?>{}.lock;
  }

  void _removeLocalFavorite(int postId) {
    ref
        .read(szurubooruFavoritesProvider(arg).notifier)
        .removeLocalFavorite(postId);
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
    SzurubooruPostVotesNotifier, IMap<int, SzurubooruPostVote?>, BooruConfig>(
  SzurubooruPostVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final szurubooruPostVoteProvider =
    Provider.autoDispose.family<SzurubooruPostVote?, int>(
  (ref, postId) {
    final config = ref.watchConfig;
    return ref.watch(szurubooruPostVotesProvider(config))[postId];
  },
);
