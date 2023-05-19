// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/toast.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
  dependencies: [
    bookmarkRepoProvider,
    downloadServiceProvider,
    settingsProvider,
  ],
);

class BookmarkNotifier extends Notifier<BookmarkState> {
  @override
  BookmarkState build() {
    getAllBookmarks();
    return const BookmarkState();
  }

  BookmarkRepository get bookmarkRepository => ref.read(bookmarkRepoProvider);

  Future<void> getAllBookmarks({
    void Function(BookmarkGetError error)? onError,
  }) async {
    bookmarkRepository.getAllBookmarks().run().then(
          (value) => value.match(
            (error) => onError?.call(error),
            (bookmarks) => state = state.copyWith(
              bookmarks: bookmarks,
            ),
          ),
        );
  }

  Future<void> addBookmarks(
    Booru booru,
    List<Post> posts, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmarks = await bookmarkRepository.addBookmarks(booru, posts);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: [...state.bookmarks, ...bookmarks],
      );
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> addBookmark(
    String url,
    Booru booru,
    Post post, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      final bookmark = await bookmarkRepository.addBookmark(booru, post);
      onSuccess?.call();
      state = state.copyWith(
        bookmarks: [...state.bookmarks, bookmark],
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
      final newFavorites = List<Bookmark>.from(state.bookmarks)
        ..remove(bookmark);
      onSuccess?.call();
      state = state.copyWith(bookmarks: newFavorites);
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
      final index = state.bookmarks.indexWhere((f) => f.id == bookmark.id);
      final newBookmarks = List<Bookmark>.from(state.bookmarks)
        ..replaceRange(index, index + 1, [bookmark]);
      onSuccess?.call();
      state = state.copyWith(bookmarks: newBookmarks);
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> downloadAllBookmarks() async {
    final settings = ref.read(settingsProvider);
    final tasks = state.bookmarks
        .map((bookmark) => ref
            .read(downloadServiceProvider)
            .downloadWithSettings(
              settings,
              url: bookmark.originalUrl,
              folderName: "Bookmarks",
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
  Future<void> addBookmarkWithToast(String url, Booru booru, Post post) =>
      addBookmark(
        url,
        booru,
        post,
        onSuccess: () => showSuccessToast('Bookmark added'),
        onError: () => showErrorToast('Failed to add bookmark'),
      );

  Future<void> addBookmarksWithToast(Booru booru, List<Post> posts) =>
      addBookmarks(
        booru,
        posts,
        onSuccess: () => showSuccessToast('${posts.length} bookmarks added'),
        onError: () => showErrorToast('Failed to add bookmarks'),
      );

  Future<void> removeBookmarkWithToast(Bookmark bookmark) => removeBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('Bookmark removed'),
        onError: () => showErrorToast('Failed to remove bookmark'),
      );

  Future<void> updateBookmarkWithToast(Bookmark bookmark) => updateBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('Bookmark updated'),
        onError: () => showErrorToast('Failed to update bookmark'),
      );

  Future<void> getAllBookmarksWithToast() => getAllBookmarks(
        onError: (error) => showErrorToast('Failed to load bookmarks: $error'),
      );
}

class BookmarkState extends Equatable {
  final List<Bookmark> bookmarks;
  final String error;

  const BookmarkState({
    this.bookmarks = const [],
    this.error = '',
  });

  BookmarkState copyWith({
    List<Bookmark>? bookmarks,
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
    return bookmarks.any((b) =>
        b.booruId == booru.index && b.originalUrl == post.originalImageUrl);
  }

  // get bookmark from Post
  Bookmark? getBookmark(Post post, BooruType booru) {
    return bookmarks.firstWhereOrNull((b) =>
        b.booruId == booru.index && b.originalUrl == post.originalImageUrl);
  }
}
