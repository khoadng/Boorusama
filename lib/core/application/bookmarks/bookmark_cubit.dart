// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';

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

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit({
    required this.bookmarkRepository,
  }) : super(const BookmarkState());

  final BookmarkRepository bookmarkRepository;

  Future<void> getAllBookmarks() async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      final bookmarks = await bookmarkRepository.getAllBookmarks();
      emit(
          state.copyWith(bookmarks: bookmarks, status: BookmarkStatus.success));
    } catch (e) {
      emitError('Failed to load favorites: $e');
    }
  }

  Future<void> addBookmark(
    String url,
    Booru booru,
    Post post,
  ) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      final bookmark = await bookmarkRepository.addBookmark(booru, post);
      emit(state.copyWith(
          bookmarks: [...state.bookmarks, bookmark],
          status: BookmarkStatus.success));
    } catch (e) {
      emitError('Failed to add favorite: $e');
    }
  }

  Future<void> removeBookmark(Bookmark bookmark) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      await bookmarkRepository.removeBookmark(bookmark);
      final newFavorites = List<Bookmark>.from(state.bookmarks)
        ..remove(bookmark);
      emit(state.copyWith(
          bookmarks: newFavorites, status: BookmarkStatus.success));
    } catch (e) {
      emitError('Failed to remove favorite: $e');
    }
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    emit(state.copyWith(status: BookmarkStatus.loading));
    try {
      await bookmarkRepository.updateBookmark(bookmark);
      final index = state.bookmarks.indexWhere((f) => f.id == bookmark.id);
      final newBookmarks = List<Bookmark>.from(state.bookmarks)
        ..replaceRange(index, index + 1, [bookmark]);
      emit(state.copyWith(
          bookmarks: newBookmarks, status: BookmarkStatus.success));
    } catch (e) {
      emitError('Failed to update favorite: $e');
    }
  }

  void emitError(String message) {
    // emitError(FavoriteStatus.failure, error: message);
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
