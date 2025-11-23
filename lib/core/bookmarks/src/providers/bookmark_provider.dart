// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../boorus/booru/types.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/downloader/types.dart';
import '../../../downloads/filename/types.dart';
import '../../../http/client/providers.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/types.dart';
import '../../../router.dart';
import '../../../settings/providers.dart';
import '../data/bookmark_convert.dart';
import '../data/providers.dart';
import '../types/bookmark.dart';
import '../types/bookmark_repository.dart';

final bookmarkProvider = AsyncNotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    settingsProvider,
  ],
);

final bookmarkUrlResolverProvider = Provider.autoDispose
    .family<ImageUrlResolver, int?>((ref, booruId) {
      final booruType = intToBooruType(booruId);

      final registry = ref.watch(booruEngineRegistryProvider);

      final repo = registry.getRepository(booruType);

      return repo?.imageUrlResolver() ?? const DefaultImageUrlResolver();
    });

class BookmarkNotifier extends AsyncNotifier<BookmarkState> {
  ImageCacheManager get _cacheManager =>
      ref.read(bookmarkImageCacheManagerProvider);

  @override
  FutureOr<BookmarkState> build() async {
    final bookmarks = await (await bookmarkRepository)
        .getAllBookmarks(
          imageUrlResolver: (booruId) =>
              ref.read(bookmarkUrlResolverProvider(booruId)),
        )
        .run();

    return bookmarks.fold(
      (error) => const BookmarkState(bookmarks: ISet.empty()),
      (bookmarks) => BookmarkState(
        bookmarks: {
          for (final bookmark in bookmarks) bookmark.uniqueId,
        }.toISet(),
      ),
    );
  }

  Future<BookmarkRepository> get bookmarkRepository =>
      ref.read(bookmarkRepoProvider.future);

  Future<void> addBookmarks(
    BooruConfigAuth config,
    Iterable<Post> posts, {
    void Function(int count)? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final booruId = config.booruIdHint;
      final currentState = await future;

      // filter out already bookmarked posts
      final filtered = posts.where(
        (post) => !currentState.isBookmarked(post, booruId),
      );

      await (await bookmarkRepository).addBookmarks(
        booruId,
        filtered,
        imageUrlResolver: (booruId) =>
            ref.read(bookmarkUrlResolverProvider(booruId)),
        postLinkGenerator: (booruId) =>
            ref.read(postLinkGeneratorProvider(config)),
      );
      onSuccess?.call(filtered.length);

      final ids = filtered
          .map((p) => BookmarkUniqueId.fromPost(p, booruId))
          .toISet();

      state = AsyncValue.data(
        currentState.copyWith(
          bookmarks: currentState.bookmarks.addAll(ids),
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> addBookmark(
    BooruConfigAuth config,
    Post post, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final booruId = config.booruIdHint;
      final currentState = await future;

      // check if post is already bookmarked
      if (currentState.isBookmarked(post, booruId)) {
        return;
      }

      final bookmark = await (await bookmarkRepository).addBookmark(
        booruId,
        post,
        imageUrlResolver: (booruId) =>
            ref.read(bookmarkUrlResolverProvider(booruId)),
        postLinkGenerator: (booruId) =>
            ref.read(postLinkGeneratorProvider(config)),
      );
      onSuccess?.call();
      state = AsyncValue.data(
        currentState.copyWith(
          bookmarks: currentState.bookmarks.add(bookmark.uniqueId),
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeBookmarkFromId(
    BookmarkUniqueId bookmarkId, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    final bookmarks = await (await bookmarkRepository).getAllBookmarksOrEmpty(
      imageUrlResolver: (booruId) =>
          ref.read(bookmarkUrlResolverProvider(booruId)),
    );

    final bookmark = bookmarks.firstWhereOrNull(
      (b) => b.uniqueId == bookmarkId,
    );

    if (bookmark == null) {
      onError?.call();
      return;
    }

    return removeBookmark(
      bookmark,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> removeBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await (await bookmarkRepository).removeBookmark(bookmark);
      // Clear all image variants
      await Future.wait([
        _cacheManager.clearCache(
          _cacheManager.generateCacheKey(bookmark.originalUrl),
        ),
        _cacheManager.clearCache(
          _cacheManager.generateCacheKey(bookmark.sampleUrl),
        ),
        _cacheManager.clearCache(
          _cacheManager.generateCacheKey(bookmark.thumbnailUrl),
        ),
      ]);
      onSuccess?.call();
      final currentState = await future;
      state = AsyncValue.data(
        currentState.copyWith(
          bookmarks: currentState.bookmarks.remove(bookmark.uniqueId),
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeBookmarks(
    Iterable<Bookmark> bookmarks, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await (await bookmarkRepository).removeBookmarks(bookmarks);
      // Clear all image variants for each bookmark
      await Future.wait(
        bookmarks.expand(
          (b) => [
            _cacheManager.clearCache(
              _cacheManager.generateCacheKey(b.originalUrl),
            ),
            _cacheManager.clearCache(
              _cacheManager.generateCacheKey(b.sampleUrl),
            ),
            _cacheManager.clearCache(
              _cacheManager.generateCacheKey(b.thumbnailUrl),
            ),
          ],
        ),
      );
      onSuccess?.call();
      final currentState = await future;
      state = AsyncValue.data(
        currentState.copyWith(
          bookmarks: currentState.bookmarks.difference(
            bookmarks.map((b) => b.uniqueId).toISet(),
          ),
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> downloadBookmarks(
    BooruConfigAuth auth,
    BooruConfigDownload download,
    List<Bookmark> bookmarks,
  ) async {
    final settings = ref.read(settingsProvider);
    final downloader = ref.read(downloadServiceProvider);
    final headers = ref.read(httpHeadersProvider(auth));

    final fileNameBuilder = fallbackFileNameBuilder;

    final tasks = bookmarks.map(
      (bookmark) async {
        final fileName = await fileNameBuilder.generate(
          settings,
          download,
          bookmark.toPost(),
          downloadUrl: bookmark.originalUrl,
        );

        return downloader.download(
          DownloadOptions.fromSettings(
            settings,
            config: download,
            url: bookmark.originalUrl,
            metadata: DownloaderMetadata(
              thumbnailUrl: bookmark.thumbnailUrl,
              fileSize: null,
              siteUrl: bookmark.sourceUrl,
              group: null,
            ),
            filename: fileName,
            headers: headers,
          ),
        );
      },
    ).toList();

    final results = await Future.wait(tasks);

    final failures = results.whereType<DownloadFailure>().toList();

    if (failures.isNotEmpty) {
      final context = navigatorKey.currentContext;

      final uniqueErrors = failures
          .map((e) => e.error.getErrorMessage())
          .toSet()
          .take(3)
          .join('\n');

      if (context != null && context.mounted) {
        showErrorToast(
          context,
          'Download failed:\n$uniqueErrors',
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
}

extension BookmarkCubitToastX on BookmarkNotifier {
  Future<void> addBookmarkWithToast(
    BooruConfigAuth config,
    Post post,
  ) async {
    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    await addBookmark(
      config,
      post,
      onSuccess: () => showSuccessToast(context, context.t.bookmark.added),
      onError: () => showErrorToast(context, context.t.bookmark.failed_to_add),
    );
  }

  Future<void> addBookmarksWithToast(
    BooruConfigAuth config,
    String booruUrl,
    Iterable<Post> posts,
  ) async {
    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    await addBookmarks(
      config,
      posts,
      onSuccess: (count) => showSuccessToast(
        context,
        context.t.bookmark.many_added.replaceAll('{0}', '$count'),
      ),
      onError: () =>
          showErrorToast(context, context.t.bookmark.failed_to_add_many),
    );
  }

  Future<void> removeBookmarkWithToast(
    BookmarkUniqueId bookmarkId, {
    void Function()? onSuccess,
  }) async {
    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    await removeBookmarkFromId(
      bookmarkId,
      onSuccess: () {
        showSuccessToast(context, context.t.bookmark.removed);
        onSuccess?.call();
      },
      onError: () =>
          showErrorToast(context, context.t.bookmark.failed_to_remove),
    );
  }
}

class BookmarkState extends Equatable {
  const BookmarkState({
    required this.bookmarks,
    this.error = '',
  });
  final ISet<BookmarkUniqueId> bookmarks;
  final String error;

  BookmarkState copyWith({
    ISet<BookmarkUniqueId>? bookmarks,
    String? error,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [bookmarks, error];
}

extension BookmarkStateX on BookmarkState {
  bool isBookmarked(Post post, int booruId) {
    return bookmarks.contains(BookmarkUniqueId.fromPost(post, booruId));
  }
}

extension BookmarkNotifierX on WidgetRef {
  BookmarkNotifier get bookmarks => read(bookmarkProvider.notifier);
}
