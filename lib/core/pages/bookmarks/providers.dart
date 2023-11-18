// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

enum BookmarkSortType {
  newest,
  oldest,
}

final filteredBookmarksProvider = Provider.autoDispose<List<Bookmark>>((ref) {
  final tags = ref.watch(selectedTagsProvider);
  final selectedBooru = ref.watch(selectedBooruProvider);
  final sortType = ref.watch(selectedBookmarkSortTypeProvider);
  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  final tagsList = tags.split(' ').where((e) => e.isNotEmpty).toList();

  return bookmarks
      .where((bookmark) => selectedBooru == null
          ? true
          : intToBooruType(bookmark.booruId) == selectedBooru)
      .where((bookmark) => tagsList.every((tag) => bookmark.tags.contains(tag)))
      .sorted((a, b) => switch (sortType) {
            BookmarkSortType.newest => b.createdAt.compareTo(a.createdAt),
            BookmarkSortType.oldest => a.createdAt.compareTo(b.createdAt)
          })
      .toList();
});

final bookmarkEditProvider = StateProvider.autoDispose<bool>((ref) => false);

final tagCountProvider = Provider.autoDispose.family<int, String>((ref, tag) {
  final tagMap = ref.watch(tagMapProvider);

  return tagMap[tag] ?? 0;
});

final booruTypeCountProvider =
    Provider.autoDispose.family<int, BooruType?>((ref, booruType) {
  if (booruType == null) {
    return ref.watch(filteredBookmarksProvider).length;
  }

  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  return bookmarks
      .where((bookmark) => intToBooruType(bookmark.booruId) == booruType)
      .length;
});

final tagColorProvider =
    FutureProvider.autoDispose.family<Color?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final settings = ref.watch(settingsProvider);
  final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
  final tagType = await tagTypeStore.get(config.booruType, tag);

  final color = ref
      .watch(booruBuilderProvider)
      ?.tagColorBuilder(settings.themeMode, tagType);

  return color;
});

final tagMapProvider = Provider<Map<String, int>>((ref) {
  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  final tagMap = <String, int>{};

  for (final bookmark in bookmarks) {
    for (final tag in bookmark.tags) {
      tagMap[tag] = (tagMap[tag] ?? 0) + 1;
    }
  }

  return tagMap;
});

final tagSuggestionsProvider = Provider.autoDispose<List<String>>((ref) {
  final tag = ref.watch(selectedTagsProvider);
  if (tag.isEmpty) return const [];

  final tagMap = ref.watch(tagMapProvider);

  final tags = tagMap.keys.toList();

  tags.sort((a, b) => tagMap[b]!.compareTo(tagMap[a]!));

  return tags.where((e) => e.contains(tag)).toList().toList();
});

final selectedTagsProvider = StateProvider.autoDispose<String>((ref) => '');
final selectedBooruProvider = StateProvider.autoDispose<BooruType?>((ref) {
  return null;
});
final selectRowCountProvider = StateProvider.autoDispose<int>((ref) => 2);

final selectedBookmarkSortTypeProvider =
    StateProvider.autoDispose<BookmarkSortType>(
        (ref) => BookmarkSortType.newest);

final availableBooruOptionsProvider = Provider.autoDispose<List<BooruType?>>(
    (ref) => [...BooruType.values, null]
        .sorted((a, b) => a?.stringify().compareTo(b?.stringify() ?? '') ?? 0)
        .where((e) => ref.watch(booruTypeCountProvider(e)) > 0)
        .toList());

final hasBookmarkProvider = Provider.autoDispose<bool>((ref) {
  final config = ref.watchConfig;
  final bookmarks = ref.watch(bookmarkProvider(config)).bookmarks;

  return bookmarks.isNotEmpty;
});
