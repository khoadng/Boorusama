// Package imports:

// Project imports:
import '../../../posts/post/post.dart';
import 'bookmark.dart';

abstract class BookmarkRepository {
  Future<Bookmark> addBookmark(
    int booruId,
    String booruUrl,
    Post post,
  );
  Future<List<Bookmark>> addBookmarks(
    int booruId,
    String booruUrl,
    Iterable<Post> posts,
  );

  Future<void> addBookmarkWithBookmarks(
    List<Bookmark> bookmarks,
  );

  Future<void> removeBookmark(Bookmark favorite);
  Future<void> updateBookmark(Bookmark favorite);
  BookmarksOrError getAllBookmarks();
}
