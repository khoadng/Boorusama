// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/preloaders/preloaders.dart';
import 'package:boorusama/boorus/core/feats/search/filter_operator.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'danbooru_post.dart';
import 'filter.dart';

mixin DanbooruPostTransformMixin<T, E> {
  BlacklistedTagsRepository get blacklistedTagsRepository;
  BooruConfig get booruConfig;
  PoolRepository get poolRepository;
  PostPreviewPreloader? get previewPreloader;
  BooruUserIdentityProvider get booruUserIdentityProvider;
  void Function(List<int> ids) get checkFavorites;
  void Function(List<int> ids) get checkVotes;

  Future<List<DanbooruPost>> transform(List<DanbooruPost> posts) async {
    final id =
        await booruUserIdentityProvider.getAccountIdFromConfig(booruConfig);
    if (id != null) {
      final ids = posts.map((e) => e.id).toList();
      checkFavorites(ids);
      checkVotes(ids);
    }

    return Future.value(posts)
        .then(filterWith(
          blacklistedTagsRepository,
          booruConfig,
          booruUserIdentityProvider,
        ))
        .then(filterFlashFiles())
        .then(preloadPreviewImagesWith(previewPreloader));
  }

  Future<List<DanbooruPost>> Function(List<DanbooruPost> posts) filterWith(
    BlacklistedTagsRepository blacklistedTagsRepository,
    BooruConfig booruConfig,
    BooruUserIdentityProvider booruUserIdentityProvider,
  ) =>
      (posts) async {
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
  final set = Set<String>.from(post.tags);
  for (final fg in fgs) {
    if (fg.groupType == FilterGroupType.single) {
      final hasTag = fg.filterItems.map((it) => it.tag).any(set.contains);
      if (hasTag) return true;
    } else {
      if (__hasBlacklistedTags(set, fg.filterItems)) return true;
    }
  }

  return false;
}

bool __hasBlacklistedTags(
  Set<String> tagSet,
  List<FilterItem> filterItems,
) {
  final operatorGroups =
      filterItems.groupListsBy((element) => element.operator);

  var isBlacklisted = false;

  if (operatorGroups[FilterOperator.none] != null) {
    if (_hasAll(tagSet, operatorGroups[FilterOperator.none]!)) {
      isBlacklisted = true;
    }
  }

  if (operatorGroups[FilterOperator.or] != null) {
    for (final orTag in operatorGroups[FilterOperator.or]!) {
      if (tagSet.contains(orTag.tag)) {
        isBlacklisted = true;
        break;
      }
    }
  }

  if (operatorGroups[FilterOperator.not] != null) {
    for (final notTag in operatorGroups[FilterOperator.not]!) {
      if (tagSet.contains(notTag.tag)) {
        isBlacklisted = false;
        break;
      }
    }
  }

  return isBlacklisted;
}

bool _hasAll(Set<String> tagSet, List<FilterItem> fg) {
  var hasAll = true;
  for (final fi in fg) {
    if (!tagSet.contains(fi.tag)) {
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
