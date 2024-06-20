// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

class BookmarkHiveRepository implements BookmarkRepository {
  const BookmarkHiveRepository(this._box);

  final Box<BookmarkHiveObject> _box;

  @override
  Future<Bookmark> addBookmark(int booruId, String booruUrl, Post post) async {
    final favoriteHiveObject = BookmarkHiveObject(
      booruId: booruId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      thumbnailUrl: post.thumbnailImageUrl,
      sampleUrl: post.sampleImageUrl,
      originalUrl: post.originalImageUrl,
      sourceUrl: post.getLink(booruUrl),
      width: post.width,
      height: post.height,
      md5: post.md5,
      tags: post.tags.toList(),
      realSourceUrl: post.source.url,
    );
    await _box.add(favoriteHiveObject);

    return tryMapBookmarkHiveObjectToBookmark(favoriteHiveObject).fold(
      (l) => Bookmark.empty,
      (r) => r,
    );
  }

  @override
  Future<void> removeBookmark(Bookmark favorite) async {
    final hiveObject = _box.values.firstWhere(
      (element) => element.key == favorite.id,
      orElse: () => throw Exception('Favorite not found'),
    );
    await hiveObject.delete();
  }

  @override
  Future<void> updateBookmark(Bookmark favorite) async {
    final obj = favoriteToHiveObject(favorite);
    _box.put(favorite.id, obj);
  }

  @override
  BookmarksOrError getAllBookmarks() => TaskEither.fromEither(
          tryGetBoxValues(_box).mapLeft(mapBoxErrorToBookmarkGetError))
      .flatMap((objects) =>
          TaskEither.fromEither(tryMapBookmarkHiveObjectsToBookmarks(objects)));

  @override
  Future<List<Bookmark>> addBookmarks(
    int booruId,
    String booruUrl,
    Iterable<Post> posts,
  ) async {
    final futures = posts.map((post) => addBookmark(booruId, booruUrl, post));
    final bookmarks = await Future.wait(futures);
    return bookmarks.toList();
  }

  @override
  Future<void> addBookmarkWithBookmarks(List<Bookmark> bookmarks) {
    final futures =
        bookmarks.map((bookmark) => _box.add(favoriteToHiveObject(bookmark)));
    return Future.wait(futures);
  }
}
