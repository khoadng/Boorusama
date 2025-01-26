// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/ref.dart';
import '../../../foundation/display.dart';
import '../../../tags/categories/providers.dart';
import '../../../theme.dart';
import '../types/bookmark.dart';
import 'bookmark_provider.dart';

enum BookmarkSortType {
  newest,
  oldest,
}

final filteredBookmarksProvider = Provider.autoDispose<List<Bookmark>>((ref) {
  final tags = ref.watch(selectedTagsProvider);
  final selectedBooruUrl = ref.watch(selectedBooruUrlProvider);
  final sortType = ref.watch(selectedBookmarkSortTypeProvider);
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  // Only split tags if there are any
  final tagsList = tags.isEmpty
      ? const <String>[]
      : tags.split(' ').where((e) => e.isNotEmpty).toList();

  // Filter in a single pass without converting to values() first
  final filtered = selectedBooruUrl == null && tagsList.isEmpty
      // No filtering needed, just sort all bookmarks
      ? bookmarks.entries.map((e) => e.value)
      : bookmarks.entries
          .where(
            (entry) =>
                // URL filter
                (selectedBooruUrl == null ||
                    entry.value.sourceUrl.contains(selectedBooruUrl)) &&
                // Tags filter
                (tagsList.isEmpty ||
                    tagsList.every((tag) => entry.value.tags.contains(tag))),
          )
          .map((e) => e.value);

  // Sort filtered results
  return filtered
      .sorted(
        (a, b) => switch (sortType) {
          BookmarkSortType.newest => b.createdAt.compareTo(a.createdAt),
          BookmarkSortType.oldest => a.createdAt.compareTo(b.createdAt)
        },
      )
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

  return bookmarks.entries.fold(
    0,
    (count, entry) =>
        intToBooruType(entry.value.booruId) == booruType ? count + 1 : count,
  );
});

final bookmarkTagColorProvider =
    FutureProvider.autoDispose.family<Color?, String>(
  (ref, tag) async {
    final config = ref.watchConfigAuth;
    final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
    final tagType = await tagTypeStore.get(config.booruType, tag);
    final colorScheme = ref.watch(colorSchemeProvider);

    final color = ref.watch(currentBooruBuilderProvider)?.tagColorBuilder(
          TagColorOptions(
            tagType: tagType,
            brightness: colorScheme.brightness,
          ),
        );

    return color;
  },
  dependencies: [colorSchemeProvider],
);

final tagMapProvider = Provider<Map<String, int>>((ref) {
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  return bookmarks.values.fold<Map<String, int>>(
    {},
    (map, bookmark) {
      for (final tag in bookmark.tags) {
        map.update(tag, (value) => value + 1, ifAbsent: () => 1);
      }
      return map;
    },
  );
});

final tagSuggestionsProvider = Provider.autoDispose<List<String>>((ref) {
  final tag = ref.watch(selectedTagsProvider);
  if (tag.isEmpty) return const [];

  final tagMap = ref.watch(tagMapProvider);

  return tagMap.entries
      .where((e) => e.key.contains(tag))
      .sorted((a, b) => b.value.compareTo(a.value))
      .take(10)
      .map((e) => e.key)
      .toList();
});

final selectedTagsProvider = StateProvider.autoDispose<String>((ref) => '');
final selectedBooruUrlProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});
final selectRowCountProvider =
    StateProvider.autoDispose.family<int, ScreenSize>(
  (ref, size) => switch (size) {
    ScreenSize.small => 2,
    ScreenSize.medium => 4,
    ScreenSize.large => 5,
    ScreenSize.veryLarge => 6,
  },
);

final selectedBookmarkSortTypeProvider =
    StateProvider.autoDispose<BookmarkSortType>(
  (ref) => BookmarkSortType.newest,
);

final availableBooruOptionsProvider = Provider.autoDispose<List<BooruType?>>(
  (ref) => [...BooruType.values, null]
      .sorted((a, b) => a?.stringify().compareTo(b?.stringify() ?? '') ?? 0)
      .where((e) => ref.watch(booruTypeCountProvider(e)) > 0)
      .toList(),
);

final availableBooruUrlsProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(bookmarkProvider).bookmarks.values.fold(
    <String>{},
    (hosts, bookmark) {
      final uri = Uri.tryParse(bookmark.sourceUrl);
      if (uri?.host != null) hosts.add(uri!.host);
      return hosts;
    },
  ).toList();
});
