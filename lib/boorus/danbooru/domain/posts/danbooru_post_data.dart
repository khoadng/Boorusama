// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

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
) =>
        (posts) => createPostData(
              favoritePostRepository,
              voteRepository,
              poolRepository,
              posts,
              currentBooruConfigRepository,
            );

Future<List<DanbooruPostData>> Function(BooruConfig? booruConfig) process(
  List<DanbooruPost> posts, {
  required Future<List<DanbooruPostData>> Function(List<DanbooruPost> posts)
      forAnonymous,
  required Future<List<DanbooruPostData>> Function(
    List<DanbooruPost> posts,
    BooruConfig booruConfig,
  )
      forUser,
}) =>
    (booruConfig) {
      return booruConfig.hasLoginDetails()
          ? forUser(posts, booruConfig!)
          : forAnonymous(posts);
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
) =>
    currentBooruConfigRepository.get().then(process(
          posts,
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
          forUser: (posts, booruConfig) async {
            List<Favorite> favs = [];
            List<PostVote> votes = [];
            List<Pool> pools = [];
            final ids = posts.map((e) => e.id).toList();

            //TODO: shoudn't hardcode limit count
            await Future.wait([
              favoritePostRepository
                  .filterFavoritesFromUserId(
                    ids,
                    booruConfig.booruUserId!,
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

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    filterWith(
  BlacklistedTagsRepository blacklistedTagsRepository,
  CurrentBooruConfigRepository currentBooruConfigRepository,
) =>
        (posts) async {
          final booruConfig = await currentBooruConfigRepository.get();

          if (!booruConfig.hasLoginDetails()) return posts;

          return blacklistedTagsRepository
              .getBlacklistedTags(booruConfig!.booruUserId!)
              .then((blacklistedTags) => filter(posts, blacklistedTags));
        };

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    filterUnsupportedFormat(
  Set<String> fileExtensions,
) =>
        (posts) async => posts
            .where((e) => !fileExtensions.contains(e.post.format))
            .where((e) => !e.post.metaTags.contains('flash'))
            .toList();

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    preloadPreviewImagesWith(
  PostPreviewPreloader? preloader,
) =>
        (posts) async {
          if (preloader != null) {
            for (final post in posts) {
              unawaited(preloader.preload(post.post));
            }
          }

          return posts;
        };
