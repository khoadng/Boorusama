// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/ref.dart';
import '../../../tags/categories/providers.dart';
import '../../../tags/tag/colors.dart';
import '../../../theme.dart';
import '../../providers.dart';
import '../types/bookmark.dart';
import '../types/bookmark_repository.dart';

enum BookmarkSortType {
  newest,
  oldest,
}

List<Bookmark> filterBookmarks({
  required List<Bookmark> bookmarks,
  required String tags,
  required BookmarkSortType sortType,
  String? selectedBooruUrl,
}) {
  // Split tags if provided, otherwise use an empty list.
  final tagsList = tags.isEmpty
      ? const <String>[]
      : tags.split(' ').where((e) => e.isNotEmpty).toList();

  // Filter bookmarks based on URL and tags.
  final filtered = selectedBooruUrl == null && tagsList.isEmpty
      ? bookmarks
      : bookmarks.where(
          (bookmark) =>
              (selectedBooruUrl == null ||
                  bookmark.sourceUrl.contains(selectedBooruUrl)) &&
              (tagsList.isEmpty ||
                  tagsList.every((tag) => bookmark.tags.contains(tag))),
        );

  // Sort filtered results.
  return filtered
      .sorted(
        (a, b) => switch (sortType) {
          BookmarkSortType.newest => b.createdAt.compareTo(a.createdAt),
          BookmarkSortType.oldest => a.createdAt.compareTo(b.createdAt)
        },
      )
      .toList();
}

final bookmarkEditProvider = StateProvider.autoDispose<bool>((ref) => false);

final tagCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, tag) async {
  final tagMap = await ref.watch(tagMapProvider.future);

  return tagMap[tag] ?? 0;
});

final bookmarkTagColorProvider =
    FutureProvider.autoDispose.family<Color?, String>(
  (ref, tag) async {
    final config = ref.watchConfigAuth;
    final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
    final tagType = await tagTypeStore.get(config.booruType, tag);
    final colorScheme = ref.watch(colorSchemeProvider);

    final color =
        ref.watch(currentBooruRepoProvider)?.tagColorGenerator().generateColor(
              TagColorOptions(
                tagType: tagType,
                colors: TagColors.fromBrightness(colorScheme.brightness),
              ),
            );

    return color;
  },
  dependencies: [colorSchemeProvider],
);

final tagMapProvider = FutureProvider<Map<String, int>>((ref) async {
  final bookmarks = await (await ref.watch(bookmarkRepoProvider.future))
      .getAllBookmarksOrEmpty(
    imageUrlResolver: (booruId) =>
        ref.read(bookmarkUrlResolverProvider(booruId)),
  );

  return bookmarks.fold<Map<String, int>>(
    {},
    (map, bookmark) {
      for (final tag in bookmark.tags) {
        map.update(tag, (value) => value + 1, ifAbsent: () => 1);
      }
      return map;
    },
  );
});

final tagSuggestionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final tag = ref.watch(tagInputProvider);
  if (tag.isEmpty) return const [];

  final tagMap = await ref.watch(tagMapProvider.future);

  return tagMap.entries
      .where((e) => e.key.contains(tag))
      .sorted((a, b) => b.value.compareTo(a.value))
      .take(10)
      .map((e) => e.key)
      .toList();
});

final selectedTagsProvider = StateProvider.autoDispose<String>((ref) => '');
final tagInputProvider = StateProvider.autoDispose<String>((ref) => '');

final selectedBooruUrlProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

final selectedBookmarkSortTypeProvider =
    StateProvider.autoDispose<BookmarkSortType>(
  (ref) => BookmarkSortType.newest,
);

final availableBooruUrlsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final bookmarks = await (await ref.watch(bookmarkRepoProvider.future))
      .getAllBookmarksOrEmpty(
    imageUrlResolver: (booruId) =>
        ref.read(bookmarkUrlResolverProvider(booruId)),
  );

  return bookmarks.fold(
    <String>{},
    (hosts, bookmark) {
      final uri = Uri.tryParse(bookmark.sourceUrl);
      if (uri?.host != null) hosts.add(uri!.host);
      return hosts;
    },
  ).toList();
});
