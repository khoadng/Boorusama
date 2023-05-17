// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

mixin DanbooruPostTransformMixin<T, E> {
  BlacklistedTagsRepository get blacklistedTagsRepository;
  CurrentBooruConfigRepository get currentBooruConfigRepository;
  PostVoteRepository get postVoteRepository;
  PoolRepository get poolRepository;
  PostPreviewPreloader? get previewPreloader;
  BooruUserIdentityProvider get booruUserIdentityProvider;
  void Function(List<int> ids) get checkFavorites;
  void Function(List<int> ids) get checkVotes;

  Future<List<DanbooruPost>> transform(List<DanbooruPost> posts) async {
    final config = await currentBooruConfigRepository.get();
    final id = await booruUserIdentityProvider.getAccountIdFromConfig(config);
    if (id != null) {
      final ids = posts.map((e) => e.id).toList();
      checkFavorites(ids);
      checkVotes(ids);
    }

    return Future.value(posts)
        .then(filterWith(
          blacklistedTagsRepository,
          currentBooruConfigRepository,
          booruUserIdentityProvider,
        ))
        .then(filterFlashFiles())
        .then(preloadPreviewImagesWith(previewPreloader));
  }

  Future<List<DanbooruPost>> Function(List<DanbooruPost> posts) filterWith(
    BlacklistedTagsRepository blacklistedTagsRepository,
    CurrentBooruConfigRepository currentBooruConfigRepository,
    BooruUserIdentityProvider booruUserIdentityProvider,
  ) =>
      (posts) async {
        final booruConfig = await currentBooruConfigRepository.get();
        final id =
            await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);

        if (id == null) return posts;

        return blacklistedTagsRepository
            .getBlacklistedTags(id)
            .then((blacklistedTags) => filter(posts, blacklistedTags));
      };

  List<DanbooruPost> filter(
    List<DanbooruPost> posts,
    List<String> blacklistedTags,
  ) {
    final groups = parseTagToFilterGroup(blacklistedTags);

    return posts.whereNot((post) => _hasBlacklistedTag(post, groups)).toList();
  }
}

bool _hasBlacklistedTag(DanbooruPost post, List<FilterGroup> fgs) {
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

//TODO: extract common method
List<DanbooruPost> filterRawPost(
  List<DanbooruPost> posts,
  List<String> blacklistedTags,
) {
  final groups = parseTagToFilterGroup(blacklistedTags);

  return posts.whereNot((post) => _hasBlacklistedTag(post, groups)).toList();
}

List<FilterGroup> parseTagToFilterGroup(List<String> tags) =>
    tags.map(stringToFilterGroup).whereNotNull().toList();

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterUnsupportedFormat(
  Set<String> fileExtensions,
) =>
        (posts) async => posts
            .where((e) => !fileExtensions.contains(e.format))
            .where((e) => !e.metaTags.contains('flash'))
            .toList();

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    preloadPreviewImagesWith(
  PostPreviewPreloader? preloader,
) =>
        (posts) async {
          if (preloader != null) {
            for (final post in posts) {
              unawaited(preloader.preload(post));
            }
          }

          return posts;
        };

Future<List<DanbooruPost>> Function(List<DanbooruPost> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});
