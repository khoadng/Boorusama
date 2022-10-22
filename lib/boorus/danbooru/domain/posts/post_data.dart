// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostData extends Equatable {
  const PostData({
    required this.post,
    required this.isFavorited,
    this.voteState = VoteState.unvote,
    required this.pools,
  });

  factory PostData.empty() => PostData(
        post: Post.empty(),
        isFavorited: false,
        pools: const [],
      );

  PostData copyWith({
    Post? post,
    bool? isFavorited,
    VoteState? voteState,
    List<Pool>? pools,
  }) =>
      PostData(
        post: post ?? this.post,
        isFavorited: isFavorited ?? this.isFavorited,
        voteState: voteState ?? this.voteState,
        pools: pools ?? this.pools,
      );

  final Post post;
  final bool isFavorited;
  final VoteState voteState;
  final List<Pool> pools;

  @override
  List<Object?> get props => [post, isFavorited, voteState, pools];
}

Future<List<PostData>> Function(List<Post> posts) createPostDataWith(
  FavoritePostRepository favoritePostRepository,
  PostVoteRepository voteRepository,
  PoolRepository poolRepository,
  AccountRepository accountRepository,
) =>
    (posts) => createPostData(
          favoritePostRepository,
          voteRepository,
          poolRepository,
          posts,
          accountRepository,
        );

Future<List<PostData>> Function(Account account) process(
  List<Post> posts, {
  required Future<List<PostData>> Function(List<Post> posts) forAnonymous,
  required Future<List<PostData>> Function(List<Post> posts, Account account)
      forUser,
}) =>
    (account) => account == Account.empty
        ? forAnonymous(posts)
        : forUser(posts, account);

Map<int, Set<Pool>> createPostPoolMap(List<Pool> pools, List<Post> posts) {
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

Future<List<PostData>> createPostData(
  FavoritePostRepository favoritePostRepository,
  PostVoteRepository voteRepository,
  PoolRepository poolRepository,
  List<Post> posts,
  AccountRepository accountRepository,
) =>
    accountRepository.get().then(process(
          posts,
          forAnonymous: (posts) async {
            final ids = posts.map((e) => e.id).toList();
            final pools = await poolRepository.getPoolsByPostIds(ids);
            final postMap = createPostPoolMap(pools, posts);

            return posts
                .map((post) => PostData(
                      post: post,
                      isFavorited: false,
                      pools: postMap[post.id]!.toList(),
                    ))
                .toList();
          },
          forUser: (posts, account) async {
            List<Favorite> favs = [];
            List<PostVote> votes = [];
            List<Pool> pools = [];
            final ids = posts.map((e) => e.id).toList();

            //TODO: shoudn't hardcode limit count
            await Future.wait([
              favoritePostRepository
                  .filterFavoritesFromUserId(
                    ids,
                    account.id,
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
                .map((post) => PostData(
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

Future<List<PostData>> Function(List<PostData> posts) filterWith(
  BlacklistedTagsRepository blacklistedTagsRepository,
) =>
    (posts) => blacklistedTagsRepository
        .getBlacklistedTags()
        .then((blacklistedTags) => filter(posts, blacklistedTags));
