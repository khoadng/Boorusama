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
import 'package:boorusama/foundation/display.dart';

enum BookmarkSortType {
  newest,
  oldest,
}

final filteredBookmarksProvider = Provider.autoDispose<List<Bookmark>>((ref) {
  final tags = ref.watch(selectedTagsProvider);
  final selectedBooruUrl = ref.watch(selectedBooruUrlProvider);
  final sortType = ref.watch(selectedBookmarkSortTypeProvider);
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  final tagsList = tags.split(' ').where((e) => e.isNotEmpty).toList();

  return bookmarks
      .where((bookmark) => selectedBooruUrl == null
          ? true
          : bookmark.sourceUrl.contains(selectedBooruUrl))
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

  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

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
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

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
final selectedBooruUrlProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});
final selectRowCountProvider = StateProvider.autoDispose
    .family<int, ScreenSize>((ref, size) => switch (size) {
          ScreenSize.small => 2,
          ScreenSize.medium => 4,
          ScreenSize.large => 5,
          ScreenSize.veryLarge => 6,
        });

final selectedBookmarkSortTypeProvider =
    StateProvider.autoDispose<BookmarkSortType>(
        (ref) => BookmarkSortType.newest);

final availableBooruOptionsProvider = Provider.autoDispose<List<BooruType?>>(
    (ref) => [...BooruType.values, null]
        .sorted((a, b) => a?.stringify().compareTo(b?.stringify() ?? '') ?? 0)
        .where((e) => ref.watch(booruTypeCountProvider(e)) > 0)
        .toList());

final availableBooruUrlsProvider = Provider.autoDispose<List<String>>((ref) {
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  return bookmarks
      .map((e) => e.sourceUrl)
      .map((e) => Uri.tryParse(e))
      .whereNotNull()
      .map((e) => e.host)
      .toSet()
      .toList();
});

final hasBookmarkProvider = Provider.autoDispose<bool>((ref) {
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  return bookmarks.isNotEmpty;
});
