// Project imports:
import '../../../posts/post/post.dart';
import 'bookmark.dart';
import 'image_url_resolver.dart';

abstract class BookmarkRepository {
  Future<Bookmark> addBookmark(
    int booruId,
    String booruUrl,
    Post post, {
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
  });
  Future<List<Bookmark>> addBookmarks(
    int booruId,
    String booruUrl,
    Iterable<Post> posts, {
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
  });

  Future<void> addBookmarkWithBookmarks(
    List<Bookmark> bookmarks,
  );

  Future<void> removeBookmark(Bookmark favorite);
  Future<void> updateBookmark(Bookmark favorite);
  BookmarksOrError getAllBookmarks({
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
  });
}
