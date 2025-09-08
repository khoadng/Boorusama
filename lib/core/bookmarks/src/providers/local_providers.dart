// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/anime-pictures/tags/providers.dart';
import '../../../../boorus/e621/tags/providers.dart';
import '../../../../boorus/gelbooru_v2/tags/providers.dart';
import '../../../../boorus/hybooru/tags/providers.dart';
import '../../../../foundation/riverpod/riverpod.dart';
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../tags/local/providers.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/tag/tag.dart';
import '../../providers.dart';
import '../data/bookmark_convert.dart';
import '../types/bookmark.dart';
import '../types/bookmark_repository.dart';
import 'bookmark_shuffle_provider.dart';

enum BookmarkSortType {
  newest,
  oldest,
  random,
}

List<Bookmark> filterBookmarks({
  required List<Bookmark> bookmarks,
  required List<String> selectedTags,
  required BookmarkSortType sortType,
  String? selectedBooruUrl,
  BookmarkShuffleState? shuffleState,
}) {
  final tagsList = selectedTags;

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

  final sorted = filtered
      .sorted(
        (a, b) => switch (sortType) {
          BookmarkSortType.newest => b.createdAt.compareTo(a.createdAt),
          BookmarkSortType.oldest => a.createdAt.compareTo(b.createdAt),
          BookmarkSortType.random => 0, // No initial sorting for random
        },
      )
      .toList();

  if (sortType == BookmarkSortType.random) {
    final activeShuffleState = shuffleState?.seed != null
        ? shuffleState!
        : const BookmarkShuffleState().withNewShuffle();
    return activeShuffleState.applyShuffleToList(sorted);
  }

  return sorted;
}

final bookmarkEditProvider = StateProvider.autoDispose<bool>((ref) => false);

final tagCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  tag,
) async {
  final tagMap = await ref.watch(tagMapProvider.future);

  return tagMap[tag] ?? 0;
});

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

final bookmarkTagResolverProvider =
    Provider.family<TagResolver, BooruConfigAuth>((ref, config) {
      return TagResolver(
        tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
        siteHost: config.url,
        cachedTagMapper: const CachedTagMapper(),
        tagRepositoryBuilder: () => ref.read(tagRepoProvider(config)),
      );
    });

final bookmarkTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            final tagResolver = ref.read(bookmarkTagResolverProvider(config));

            if (post case final BookmarkPost bookmarkPost) {
              final originalPost = bookmarkPost.toOriginalPost();

              //FIXME: Need a better way to handle different booru types
              if (config.booruType == BooruType.gelbooruV2) {
                return ref.read(
                  gelbooruV2TagsFromIdProvider((
                    config,
                    originalPost.id,
                  )).future,
                );
              } else if (config.booruType == BooruType.hybooru) {
                return ref.read(
                  hybooruTagsFromIdProvider((config, originalPost.id)).future,
                );
              } else if (config.booruType == BooruType.zerochan) {
                return ref.read(
                  hybooruTagsFromIdProvider((config, originalPost.id)).future,
                );
              } else if (config.booruType == BooruType.animePictures) {
                return ref.read(
                  animePicturesTagsFromIdProvider((
                    config,
                    originalPost.id,
                  )).future,
                );
              } else if (config.booruType == BooruType.e621) {
                final resolver = ref.read(e621TagResolverProvider(config));

                return resolver.resolveRawTags(bookmarkPost.tags);
              } else {
                final tags = bookmarkPost.tags;

                return tagResolver.resolveRawTags(tags);
              }
            } else {
              return TagExtractor.extractTagsFromGenericPost(post);
            }
          },
        );
      },
    );
