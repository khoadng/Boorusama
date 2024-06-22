// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/functional.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    bookmarkRepoProvider,
    settingsProvider,
    downloadServiceProvider,
  ],
);

class BookmarkNotifier extends Notifier<BookmarkState> {
  @override
  BookmarkState build() {
    getAllBookmarks();
    return BookmarkState(bookmarks: <Bookmark>[].lock);
  }

  BookmarkRepository get bookmarkRepository => ref.read(bookmarkRepoProvider);

  Future<void> getAllBookmarks({
    void Function(BookmarkGetError error)? onError,
  }) async {
    bookmarkRepository.getAllBookmarks().run().then(
          (value) => value.match(
            (error) => onError?.call(error),
            (bookmarks) => state = state.copyWith(
              bookmarks: bookmarks.lock,
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
      state = state.copyWith(bookmarks: state.bookmarks.addAll(bookmarks));
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
      state = state.copyWith(bookmarks: state.bookmarks.add(bookmark));
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
        bookmarks: state.bookmarks.remove(bookmark),
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
        bookmarks: state.bookmarks.replaceFirstWhere(
          (item) => item.id == bookmark.id,
          (item) => bookmark,
        ),
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> exportAllBookmarks(String path) async {
    try {
      // request permission
      final deviceInfo = ref.read(deviceInfoProvider);
      final status = await checkMediaPermissions(deviceInfo);

      if (status != PermissionStatus.granted) {
        final status = await requestMediaPermissions(deviceInfo);

        if (status != PermissionStatus.granted) {
          showErrorToast('Permission to access storage denied');
          return;
        }
      }
      final dir = Directory(path);
      final date = DateFormat('yyyy.MM.dd.mm.ss').format(DateTime.now());
      final file = File(join(dir.path, 'boorusama_bookmarks_$date.json'));
      final json =
          state.bookmarks.map((bookmark) => bookmark.toJson()).toList();
      final jsonString = jsonEncode(json);
      await file.writeAsString(jsonString);

      showSuccessToast(
        '${state.bookmarks.length} bookmarks exported to ${file.path}',
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      showErrorToast('Failed to export bookmarks: $e');
    }
  }

  Future<void> importBookmarks(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final json = jsonDecode(jsonString) as List<dynamic>;
      try {
        final bookmarks = json
            .map((bookmark) => Bookmark.fromJson(bookmark))
            .toList()
            // remove duplicates
            .where((bookmark) => !state.bookmarks
                .where((b) => b.originalUrl == bookmark.originalUrl)
                .isNotEmpty)
            .toList();

        await bookmarkRepository.addBookmarkWithBookmarks(bookmarks);
        await getAllBookmarks();
        showSuccessToast(
          '${bookmarks.length} bookmarks imported',
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        showErrorToast('Failed to import bookmarks');
      }
    } catch (e) {
      showErrorToast('Invalid export file');
    }
  }

  Future<void> downloadBookmarks(
      BooruConfig config, List<Bookmark> bookmarks) async {
    final settings = ref.read(settingsProvider);
    final tasks = bookmarks
        .map((bookmark) => ref
            .read(downloadServiceProvider(config))
            .downloadWithSettings(
              settings,
              config: config,
              url: bookmark.originalUrl,
              metadata: DownloaderMetadata(
                thumbnailUrl: bookmark.thumbnailUrl,
                fileSize: null,
                siteUrl: bookmark.sourceUrl,
              ),
              fileNameBuilder: () =>
                  bookmark.md5 + extension(bookmark.originalUrl),
            )
            .run())
        .toList();
    await Future.wait(tasks);
  }
}

extension BookmarkNotifierX on WidgetRef {
  BookmarkNotifier get bookmarks => read(bookmarkProvider.notifier);
}

extension BookmarkCubitToastX on BookmarkNotifier {
  Future<void> addBookmarkWithToast(
    int booruId,
    String booruUrl,
    Post post,
  ) =>
      addBookmark(
        booruId,
        booruUrl,
        post,
        onSuccess: () => showSuccessToast('bookmark.added'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_add'.tr()),
      );

  Future<void> addBookmarksWithToast(
    int booruId,
    String booruUrl,
    Iterable<Post> posts,
  ) =>
      addBookmarks(
        booruId,
        booruUrl,
        posts,
        onSuccess: () => showSuccessToast(
          'bookmark.many_added'.tr().replaceAll('{0}', '${posts.length}'),
        ),
        onError: () => showErrorToast('bookmark.failed_to_add_many'.tr()),
      );

  Future<void> removeBookmarkWithToast(Bookmark bookmark) => removeBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('bookmark.removed'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_remove'.tr()),
      );

  Future<void> updateBookmarkWithToast(Bookmark bookmark) => updateBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('bookmark.updated'.tr()),
        onError: () => showErrorToast('bookmark.failed_to_update'.tr()),
      );

  Future<void> getAllBookmarksWithToast() => getAllBookmarks(
        onError: (error) => showErrorToast(
            'bookmark.failed_to_load'.tr().replaceAll('{0}', error.toString())),
      );
}

class BookmarkState extends Equatable {
  final IList<Bookmark> bookmarks;
  final String error;

  const BookmarkState({
    required this.bookmarks,
    this.error = '',
  });

  BookmarkState copyWith({
    IList<Bookmark>? bookmarks,
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
    return bookmarks.any((b) => b.originalUrl == post.originalImageUrl);
  }

  // get bookmark from Post
  Bookmark? getBookmark(Post post, BooruType booru) {
    return bookmarks
        .firstWhereOrNull((b) => b.originalUrl == post.originalImageUrl);
  }
}
