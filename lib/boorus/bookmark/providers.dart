// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/bookmarks/providers.dart';
import '../../core/bookmarks/src/data/bookmark_convert.dart';
import '../../core/bookmarks/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';

final bookmarkBooruRepoProvider =
    Provider.family<PostRepository<BookmarkPost>, BooruConfigSearch>((
      ref,
      config,
    ) {
      return PostRepositoryBuilder(
        tagComposer: ref.watch(defaultTagQueryComposerProvider(config)),
        getSettings: () async => ref.read(imageListingSettingsProvider),
        fetchSingle: (id, {options}) async {
          final bookmarkRepo = await ref.read(bookmarkRepoProvider.future);
          final bookmarks = await bookmarkRepo.getAllBookmarksOrEmpty(
            imageUrlResolver: (booruId) =>
                ref.read(bookmarkUrlResolverProvider(booruId)),
          );
          final numericId = id as NumericPostId?;

          if (numericId == null) return null;

          try {
            final bookmark = bookmarks.firstWhere(
              (b) => b.id == numericId.value,
            );
            return bookmark.toPost();
          } catch (e) {
            return null;
          }
        },
        fetch: (tags, page, {limit, options}) async {
          final bookmarkRepo = await ref.read(bookmarkRepoProvider.future);
          final bookmarks = await bookmarkRepo.getAllBookmarksOrEmpty(
            imageUrlResolver: (booruId) =>
                ref.read(bookmarkUrlResolverProvider(booruId)),
          );

          var posts = bookmarks.map((bookmark) => bookmark.toPost()).toList();

          // Apply basic tag filtering if tags are provided
          if (tags.isNotEmpty) {
            final tagList = tags
                .map((t) => t.toLowerCase())
                .where((t) => t.isNotEmpty)
                .toList();
            posts = posts.where((post) {
              final postTags = post.tags.map((t) => t.toLowerCase()).toSet();
              return tagList.every((tag) => postTags.contains(tag));
            }).toList();
          }

          // Simple pagination
          final startIndex = (page - 1) * (limit ?? 20);
          final endIndex = startIndex + (limit ?? 20);

          if (startIndex >= posts.length) {
            return PostResult(posts: const [], total: posts.length);
          }

          final paginatedPosts = posts.sublist(
            startIndex,
            endIndex > posts.length ? posts.length : endIndex,
          );

          return PostResult(posts: paginatedPosts, total: posts.length);
        },
      );
    });
