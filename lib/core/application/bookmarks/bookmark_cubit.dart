// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/toast.dart';

enum BookmarkStatus { initial, loading, success, failure }

class BookmarkState extends Equatable {
  final List<Bookmark> bookmarks;
  final BookmarkStatus status;
  final String error;

  const BookmarkState({
    this.bookmarks = const [],
    this.status = BookmarkStatus.initial,
    this.error = '',
  });

  BookmarkState copyWith({
    List<Bookmark>? bookmarks,
    BookmarkStatus? status,
    String? error,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [bookmarks, status, error];
}

class BookmarkCubit extends Cubit<BookmarkState> with SettingsRepositoryMixin {
  BookmarkCubit({
    required this.bookmarkRepository,
    required this.downloadService,
    required this.settingsRepository,
  }) : super(const BookmarkState());

  final BookmarkRepository bookmarkRepository;
  final DownloadService2 downloadService;
  @override
  final SettingsRepository settingsRepository;

  Future<void> getAllBookmarks({
    void Function(BookmarkGetError error)? onError,
  }) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    bookmarkRepository.getAllBookmarks().run().then((value) => value.match(
          (error) => onError?.call(error),
          (bookmarks) => emit(state.copyWith(
            bookmarks: bookmarks,
            status: BookmarkStatus.success,
          )),
        ));
  }

  Future<void> addBookmark(
    String url,
    Booru booru,
    Post post, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      final bookmark = await bookmarkRepository.addBookmark(booru, post);
      onSuccess?.call();
      emit(state.copyWith(
          bookmarks: [...state.bookmarks, bookmark],
          status: BookmarkStatus.success));
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> removeBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      await bookmarkRepository.removeBookmark(bookmark);
      final newFavorites = List<Bookmark>.from(state.bookmarks)
        ..remove(bookmark);
      onSuccess?.call();
      emit(state.copyWith(
          bookmarks: newFavorites, status: BookmarkStatus.success));
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> updateBookmark(
    Bookmark bookmark, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      await bookmarkRepository.updateBookmark(bookmark);
      final index = state.bookmarks.indexWhere((f) => f.id == bookmark.id);
      final newBookmarks = List<Bookmark>.from(state.bookmarks)
        ..replaceRange(index, index + 1, [bookmark]);
      onSuccess?.call();
      emit(state.copyWith(
          bookmarks: newBookmarks, status: BookmarkStatus.success));
    } catch (e) {
      onError?.call();
    }
  }

  Future<void> downloadAllBookmarks() async {
    final settings = await getOrDefault();
    final tasks = state.bookmarks
        .map((bookmark) => downloadService
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

extension BookmarkCubitToastX on BookmarkCubit {
  Future<void> addBookmarkWithToast(String url, Booru booru, Post post) =>
      addBookmark(
        url,
        booru,
        post,
        onSuccess: () => showSuccessToast('Bookmark added successfully'),
        onError: () => showErrorToast('Failed to add bookmark'),
      );

  Future<void> removeBookmarkWithToast(Bookmark bookmark) => removeBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('Bookmark removed successfully'),
        onError: () => showErrorToast('Failed to remove bookmark'),
      );

  Future<void> updateBookmarkWithToast(Bookmark bookmark) => updateBookmark(
        bookmark,
        onSuccess: () => showSuccessToast('Bookmark updated successfully'),
        onError: () => showErrorToast('Failed to update bookmark'),
      );

  Future<void> getAllBookmarksWithToast() => getAllBookmarks(
        onError: (error) => showErrorToast('Failed to load bookmarks: $error'),
      );
}
