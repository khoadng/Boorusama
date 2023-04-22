// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus.dart';

class DanbooruPostData extends Equatable {
  const DanbooruPostData({
    required this.post,
    required this.isFavorited,
    this.voteState = VoteState.unvote,
    required this.pools,
    List<Note>? notes,
  }) : _notes = notes;

  factory DanbooruPostData.empty() => DanbooruPostData(
        post: DanbooruPost.empty(),
        isFavorited: false,
        pools: const [],
      );

  DanbooruPostData copyWith({
    DanbooruPost? post,
    bool? isFavorited,
    VoteState? voteState,
    List<Pool>? pools,
    List<Note>? notes,
  }) =>
      DanbooruPostData(
        post: post ?? this.post,
        isFavorited: isFavorited ?? this.isFavorited,
        voteState: voteState ?? this.voteState,
        pools: pools ?? this.pools,
        notes: notes ?? _notes,
      );

  final DanbooruPost post;
  final bool isFavorited;
  final VoteState voteState;
  final List<Pool> pools;
  List<Note> get notes => _notes ?? [];

  final List<Note>? _notes;

  @override
  List<Object?> get props => [post, isFavorited, voteState, pools, _notes];
}

Future<List<DanbooruPostData>> Function(List<DanbooruPost> posts)
    createPostDataWith(
  FavoritePostRepository favoritePostRepository,
  PostVoteRepository voteRepository,
  PoolRepository poolRepository,
  CurrentBooruConfigRepository currentBooruConfigRepository,
  BooruUserIdentityProvider booruUserIdentityProvider,
) =>
        (posts) => createPostData(
              favoritePostRepository,
              voteRepository,
              poolRepository,
              posts,
              currentBooruConfigRepository,
              booruUserIdentityProvider,
            );

Future<List<DanbooruPostData>> Function(BooruConfig? booruConfig) process(
  List<DanbooruPost> posts,
  BooruUserIdentityProvider booruUserIdentityProvider, {
  required Future<List<DanbooruPostData>> Function(List<DanbooruPost> posts)
      forAnonymous,
  required Future<List<DanbooruPostData>> Function(
    List<DanbooruPost> posts,
    int id,
  )
      forUser,
}) =>
    (booruConfig) async {
      final id =
          await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);

      return id != null ? forUser(posts, id) : forAnonymous(posts);
    };

Map<int, Set<Pool>> createPostPoolMap(
  List<Pool> pools,
  List<DanbooruPost> posts,
) {
  final postMap = {for (final p in posts) p.id: <Pool>{}};

  for (final p in pools) {
    // ignore: prefer_foreach
    for (final i in p.postIds) {
      if (postMap.containsKey(i)) {
        postMap[i]!.add(p);
      }
    }
  }

  return postMap;
}

Future<List<DanbooruPostData>> createPostData(
  FavoritePostRepository favoritePostRepository,
  PostVoteRepository voteRepository,
  PoolRepository poolRepository,
  List<DanbooruPost> posts,
  CurrentBooruConfigRepository currentBooruConfigRepository,
  BooruUserIdentityProvider booruUserIdentityProvider,
) =>
    currentBooruConfigRepository.get().then(process(
          posts,
          booruUserIdentityProvider,
          forAnonymous: (posts) async {
            final ids = posts.map((e) => e.id).toList();
            final pools = await poolRepository.getPoolsByPostIds(ids);
            final postMap = createPostPoolMap(pools, posts);

            return posts
                .map((post) => DanbooruPostData(
                      post: post,
                      isFavorited: false,
                      pools: postMap[post.id]!.toList(),
                    ))
                .toList();
          },
          forUser: (posts, userId) async {
            List<Favorite> favs = [];
            List<PostVote> votes = [];
            List<Pool> pools = [];
            final ids = posts.map((e) => e.id).toList();

            //TODO: shoudn't hardcode limit count
            await Future.wait([
              favoritePostRepository
                  .filterFavoritesFromUserId(
                    ids,
                    userId,
                    200,
                  )
                  .then((value) => favs = value),
              voteRepository.getPostVotes(ids).then((value) => votes = value),
              poolRepository
                  .getPoolsByPostIds(ids)
                  .then((value) => pools = value),
            ]);

            final favSet = favs.map((e) => e.postId).toSet();
            final voteMap = {for (final v in votes) v.postId: v.score};
            final postMap = createPostPoolMap(pools, posts);

            return posts
                .map((post) => DanbooruPostData(
                      post: post,
                      isFavorited: favSet.contains(post.id),
                      voteState: voteMap.containsKey(post.id)
                          ? voteStateFromScore(voteMap[post.id]!)
                          : VoteState.unvote,
                      pools: postMap[post.id]!.toList(),
                    ))
                .toList();
          },
        ));
