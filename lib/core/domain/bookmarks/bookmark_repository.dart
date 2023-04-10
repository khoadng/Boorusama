// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'bookmark.dart';

abstract class BookmarkRepository {
  Future<Bookmark> addBookmark(Booru booru, Post post);
  Future<void> removeBookmark(Bookmark favorite);
  Future<void> updateBookmark(Bookmark favorite);
  Future<List<Bookmark>> getAllBookmarks();
}
