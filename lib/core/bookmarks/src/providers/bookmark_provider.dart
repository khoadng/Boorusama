// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../backups/types.dart';
import '../../../boorus/booru/booru.dart';
import '../../../configs/config.dart';
import '../../../downloads/downloader.dart';
import '../../../foundation/animations.dart';
import '../../../foundation/path.dart';
import '../../../foundation/permissions.dart';
import '../../../foundation/toast.dart';
import '../../../http/http.dart';
import '../../../http/providers.dart';
import '../../../images/providers.dart';
import '../../../info/device_info.dart';
import '../../../posts/post/post.dart';
import '../../../settings/providers.dart';
import '../data/providers.dart';
import '../types/bookmark.dart';
import '../types/bookmark_repository.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    bookmarkRepoProvider,
    settingsProvider,
    downloadServiceProvider,
  ],
);

final hasBookmarkProvider = Provider.autoDispose<bool>((ref) {
  final bookmarks = ref.watch(bookmarkProvider).bookmarks;

  return bookmarks.isNotEmpty;
});

class BookmarkNotifier extends Notifier<BookmarkState> {
  @override
  BookmarkState build() {
    getAllBookmarks();
    return const BookmarkState(bookmarks: IMap.empty());
  }

  BookmarkRepository get bookmarkRepository => ref.read(bookmarkRepoProvider);

  Future<void> getAllBookmarks({
    void Function(BookmarkGetError error)? onError,
  }) {
    return bookmarkRepository.getAllBookmarks().run().then(
          (value) => value.match(
            (error) => onError?.call(error),
            (bookmarks) => state = state.copyWith(
              bookmarks: IMap.fromIterables(
                bookmarks.map((b) => b.originalUrl),
                bookmarks,
              ),
            ),
          ),
        );
  }

  Future<void> addBookmarks(
    int booruId,
    String booruUrl,
    Iterable<Post> posts, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmarks =
          await bookmarkRepository.addBookmarks(booruId, booruUrl, posts);
      onSuccess?.call();

      final map = IMap.fromIterables(
        bookmarks.map((b) => b.originalUrl),
        bookmarks,
      );

      state = state.copyWith(bookmarks: state.bookmarks.addAll(map));
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> addBookmark(
    int booruId,
    String booruUrl,
    Post post, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmark =
          await bookmarkRepository.addBookmark(booruId, booruUrl, post);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.add(bookmark.originalUrl, bookmark),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await bookmarkRepository.removeBookmark(bookmark);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: state.bookmarks.remove(bookmark.originalUrl),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> updateBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      await bookmarkRepository.updateBookmark(bookmark);
      onSuccess?.call();

      state = state.copyWith(
        bookmarks: state.bookmarks.update(
          bookmark.originalUrl,
          (b) => bookmark,
          ifAbsent: () => bookmark,
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> exportAllBookmarks(BuildContext context, String path) async {
    try {
      // request permission
      final deviceInfo = ref.read(deviceInfoProvider);
      final status = await checkMediaPermissions(deviceInfo);

      if (status != PermissionStatus.granted) {
        final status = await requestMediaPermissions(deviceInfo);

        if (context.mounted && status != PermissionStatus.granted) {
          showErrorToast(context, 'Permission to access storage denied');
          return;
        }
      }
      final dir = Directory(path);
      final date = DateFormat('yyyy.MM.dd.mm.ss').format(DateTime.now());
      final file = File(join(dir.path, 'boorusama_bookmarks_$date.json'));
      final json =
          state.bookmarks.values.map((bookmark) => bookmark.toJson()).toList();
      final jsonString = jsonEncode(json);
      await file.writeAsString(jsonString);

      if (context.mounted) {
        showSuccessToast(
          context,
          '${state.bookmarks.length} bookmarks exported to ${file.path}',
          duration: AppDurations.longToast,
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (e is PathAccessException) {
          showErrorToast(context, kInvalidLocationMessage);
        } else {
          showErrorToast(context, 'Failed to export bookmarks: $e');
        }
      }
    }
  }

  Future<void> importBookmarks(BuildContext context, File file) async {
    try {
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as List<dynamic>;
      try {
        final bookmarks = json
            .map((bookmark) => Bookmark.fromJson(bookmark))
            .toList()
            // remove duplicates
            .where(
              (bookmark) => !state.bookmarks.containsKey(bookmark.originalUrl),
            )
            .toList();

        await bookmarkRepository.addBookmarkWithBookmarks(bookmarks);
        await getAllBookmarks();

        if (context.mounted) {
          showSuccessToast(
            context,
            '${bookmarks.length} bookmarks imported',
            duration: AppDurations.longToast,
          );
        }
      } catch (e) {
        if (context.mounted) {
          showErrorToast(
            context,
            'Failed to import bookmarks',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorToast(context, 'Invalid export file');
      }
    }
  }

  Future<void> downloadBookmarks(
    BooruConfig config,
    List<Bookmark> bookmarks,
  ) async {
    final settings = ref.read(settingsProvider);
    final tasks = bookmarks
        .map(
          (bookmark) => ref
              .read(downloadServiceProvider(config.auth))
              .downloadWithSettings(
            settings,
            config: config,
            url: bookmark.originalUrl,
            metadata: DownloaderMetadata(
              thumbnailUrl: bookmark.thumbnailUrl,
              fileSize: null,
              siteUrl: bookmark.sourceUrl,
              group: null,
            ),
            filename: bookmark.md5 + extension(bookmark.originalUrl),
            headers: {
              AppHttpHeaders.userAgentHeader:
                  ref.read(userAgentProvider(config.auth.booruType)),
              ...ref.read(extraHttpHeaderProvider(config.auth)),
              ...ref.read(cachedBypassDdosHeadersProvider(config.url)),
            },
          ).run(),
        )
        .toList();
    await Future.wait(tasks);
  }
}

extension BookmarkCubitToastX on BookmarkNotifier {
  Future<void> addBookmarkWithToast(
    BuildContext context,
    int booruId,
    String booruUrl,
    Post post,
  ) async {
    await addBookmark(
      booruId,
      booruUrl,
      post,
      onSuccess: () => showSuccessToast(context, 'bookmark.added'.tr()),
      onError: () => showErrorToast(context, 'bookmark.failed_to_add'.tr()),
    );
  }

  Future<void> addBookmarksWithToast(
    BuildContext context,
    int booruId,
    String booruUrl,
    Iterable<Post> posts,
  ) async {
    await addBookmarks(
      booruId,
      booruUrl,
      posts,
      onSuccess: () => showSuccessToast(
        context,
        'bookmark.many_added'.tr().replaceAll('{0}', '${posts.length}'),
      ),
      onError: () =>
          showErrorToast(context, 'bookmark.failed_to_add_many'.tr()),
    );
  }

  Future<void> removeBookmarkWithToast(
    BuildContext context,
    Bookmark bookmark,
  ) async {
    await removeBookmark(
      bookmark,
      onSuccess: () => showSuccessToast(context, 'bookmark.removed'.tr()),
      onError: () => showErrorToast(context, 'bookmark.failed_to_remove'.tr()),
    );
  }

  Future<void> updateBookmarkWithToast(
    BuildContext context,
    Bookmark bookmark,
  ) async {
    await updateBookmark(
      bookmark,
      onSuccess: () => showSuccessToast(context, 'bookmark.updated'.tr()),
      onError: () => showErrorToast(context, 'bookmark.failed_to_update'.tr()),
    );
  }

  Future<void> getAllBookmarksWithToast(
    BuildContext context,
  ) async {
    await getAllBookmarks(
      onError: (error) => showErrorToast(
        context,
        'bookmark.failed_to_load'.tr().replaceAll('{0}', error.toString()),
      ),
    );
  }
}

class BookmarkState extends Equatable {
  const BookmarkState({
    required this.bookmarks,
    this.error = '',
  });
  final IMap<String, Bookmark> bookmarks;
  final String error;

  BookmarkState copyWith({
    IMap<String, Bookmark>? bookmarks,
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

extension BookmarkCubitX on BookmarkState {
  // check if a post is bookmarked
  bool isBookmarked(Post post, BooruType booru) {
    return bookmarks.containsKey(post.originalImageUrl);
  }

  // get bookmark from Post
  Bookmark? getBookmark(Post post, BooruType booru) {
    return bookmarks[post.originalImageUrl];
  }
}

extension BookmarkNotifierX on WidgetRef {
  BookmarkNotifier get bookmarks => read(bookmarkProvider.notifier);
}
