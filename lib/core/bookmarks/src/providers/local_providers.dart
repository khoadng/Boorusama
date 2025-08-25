// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/riverpod/riverpod.dart';
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../tags/categories/providers.dart';
import '../../../tags/local/providers.dart';
import '../../../tags/tag/colors.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/tag/tag.dart';
import '../../../theme.dart';
import '../../providers.dart';
import '../data/bookmark_convert.dart';
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
          BookmarkSortType.oldest => a.createdAt.compareTo(b.createdAt),
        },
      )
      .toList();
}

final bookmarkEditProvider = StateProvider.autoDispose<bool>((ref) => false);

final tagCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  tag,
) async {
  final tagMap = await ref.watch(tagMapProvider.future);

  return tagMap[tag] ?? 0;
});

final bookmarkTagColorProvider = FutureProvider.autoDispose
    .family<Color?, (BooruConfigAuth, String)>(
      (ref, params) async {
        final (config, tag) = params;
        final tagTypeStore = await ref.watch(booruTagTypeStoreProvider.future);
        final tagType = await tagTypeStore.getTagCategory(config.url, tag);
        final colorScheme = ref.watch(colorSchemeProvider);

        final color = ref
            .watch(booruRepoProvider(config))
            ?.tagColorGenerator()
            .generateColor(
              TagColorOptions(
                tagType: tagType,
                colors: TagColors.fromBrightness(colorScheme.brightness),
              ),
            );

        return color;
      },
      dependencies: [colorSchemeProvider],
    );

final tagMapProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  ref.cacheFor(const Duration(seconds: 3));
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

final sortedTagsProvider =
    FutureProvider.autoDispose<List<MapEntry<String, int>>>((
      ref,
    ) async {
      final tagMap = await ref.watch(tagMapProvider.future);
      return tagMap.entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .toList();
    });

final tagSuggestionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final tagString = ref.watch(tagInputProvider);
  if (tagString.isEmpty) return const [];

  final tags = tagString.trim().split(' ');

  final tag = tags.lastOrNull?.trim();

  if (tag == null || tag.isEmpty) return const [];

  final sortedTags = await ref.watch(sortedTagsProvider.future);

  return sortedTags.take(10).map((e) => e.key).toList();
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

final availableBooruUrlsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
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

final bookmarkTagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>?, (BooruConfigAuth, BookmarkPost)>((
      ref,
      params,
    ) async {
      ref.cacheFor(const Duration(seconds: 30));

      final config = params.$1;
      final post = params.$2;

      final tagExtractor = ref.watch(bookmarkTagExtractorProvider(config));

      final tags = await tagExtractor.extractTags(
        post,
      );

      return createTagGroupItems(tags);
    });

final bookmarkTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            // Use read to avoid circular dependency
            final tagResolver = ref.read(tagResolverProvider(config));

            if (post case final BookmarkPost bookmarkPost) {
              final tags = bookmarkPost.tags;

              return tagResolver.resolveRawTags(tags);
            } else {
              return TagExtractor.extractTagsFromGenericPost(post);
            }
          },
        );
      },
    );
