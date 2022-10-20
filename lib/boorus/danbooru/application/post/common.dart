// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

Future<List<PostData>> createPostData(
  FavoritePostRepository favoritePostRepository,
  PostVoteRepository voteRepository,
  PoolRepository poolRepository,
  List<Post> posts,
  AccountRepository accountRepository,
) async {
  Map<int, Set<Pool>> createPostPoolMap(List<Pool> pools) {
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

  final account = await accountRepository.get();
  final ids = posts.map((e) => e.id).toList();

  if (account == Account.empty) {
    final pools = await poolRepository.getPoolsByPostIds(ids);
    final postMap = createPostPoolMap(pools);

    return posts
        .map((post) => PostData(
              post: post,
              isFavorited: false,
              pools: postMap[post.id]!.toList(),
            ))
        .toList();
  } else {
    List<Favorite> favs = [];
    List<PostVote> votes = [];
    List<Pool> pools = [];

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
      poolRepository.getPoolsByPostIds(ids).then((value) => pools = value),
    ]);

    final favSet = favs.map((e) => e.postId).toSet();
    final voteMap = {for (final v in votes) v.postId: v.score};
    final postMap = createPostPoolMap(pools);

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
  }
}

List<PostData> filter(
  List<PostData> posts,
  List<String> blacklistedTags,
) {
  final groups = _parse(blacklistedTags);

  return posts
      .whereNot((post) => _hasBlacklistedTag(post.post, groups))
      .toList();
}

//TODO: extract common method
List<Post> filterRawPost(
  List<Post> posts,
  List<String> blacklistedTags,
) {
  final groups = _parse(blacklistedTags);

  return posts.whereNot((post) => _hasBlacklistedTag(post, groups)).toList();
}

List<PostData> filterBlacklisted(
  List<PostData> posts,
  List<String> blacklistedTags,
) {
  final groups = _parse(blacklistedTags);

  return posts.where((post) => _hasBlacklistedTag(post.post, groups)).toList();
}

List<FilterGroup> _parse(List<String> tags) =>
    tags.map(stringToFilterGroup).whereNotNull().toList();

bool _hasBlacklistedTag(Post post, List<FilterGroup> fgs) {
  final tagMap = Map<String, String>.fromIterable(post.tags);
  for (final fg in fgs) {
    if (fg.groupType == FilterGroupType.single) {
      final hasTag = fg.filterItems.map((it) => it.tag).any(tagMap.containsKey);
      if (hasTag) return true;
    } else {
      if (__hasBlacklistedTags(tagMap, fg.filterItems)) return true;
    }
  }

  return false;
}

bool __hasBlacklistedTags(
  Map<String, String> tagMap,
  List<FilterItem> filterItems,
) {
  final operatorGroups =
      filterItems.groupListsBy((element) => element.operator);

  var isBlacklisted = false;

  if (operatorGroups[FilterOperator.none] != null) {
    if (_hasAll(tagMap, operatorGroups[FilterOperator.none]!)) {
      isBlacklisted = true;
    }
  }

  if (operatorGroups[FilterOperator.or] != null) {
    for (final orTag in operatorGroups[FilterOperator.or]!) {
      if (tagMap.containsKey(orTag.tag)) {
        isBlacklisted = true;
        break;
      }
    }
  }

  if (operatorGroups[FilterOperator.not] != null) {
    for (final notTag in operatorGroups[FilterOperator.not]!) {
      if (tagMap.containsKey(notTag.tag)) {
        isBlacklisted = false;
        break;
      }
    }
  }

  return isBlacklisted;
}

bool _hasAll(Map<String, String> tagMap, List<FilterItem> fg) {
  var hasAll = true;
  for (final fi in fg) {
    if (!tagMap.containsKey(fi.tag)) {
      hasAll = false;
      break;
    }
  }

  return hasAll;
}
