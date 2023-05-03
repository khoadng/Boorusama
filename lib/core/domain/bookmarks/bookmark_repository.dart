// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/functional.dart';
import 'bookmark.dart';

enum BookmarkGetError {
  nullField,
  databaseClosed,
  unknown,
}

typedef BookmarksOrError = TaskEither<BookmarkGetError, List<Bookmark>>;

abstract class BookmarkRepository {
  Future<Bookmark> addBookmark(Booru booru, Post post);
  Future<void> removeBookmark(Bookmark favorite);
  Future<void> updateBookmark(Bookmark favorite);
  BookmarksOrError getAllBookmarks();
}
