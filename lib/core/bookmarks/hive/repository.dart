// Package imports:
import 'package:foundation/foundation.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/posts/sources/source.dart';
import '../bookmark.dart';
import '../bookmark_convert.dart';
import 'object.dart';

class BookmarkHiveRepository implements BookmarkRepository {
  const BookmarkHiveRepository(this._box);

  final Box<BookmarkHiveObject> _box;

  @override
  Future<Bookmark> addBookmark(int booruId, String booruUrl, Post post) async {
    final now = DateTime.now();

    final favoriteHiveObject = BookmarkHiveObject(
      booruId: booruId,
      createdAt: now,
      updatedAt: now,
      thumbnailUrl: post.thumbnailImageUrl,
      sampleUrl: post.sampleImageUrl,
      originalUrl: post.originalImageUrl,
      sourceUrl: post.getLink(booruUrl),
      width: post.width,
      height: post.height,
      md5: post.md5,
      tags: post.tags.toList(),
      realSourceUrl: post.source.url,
      format: post.format,
    );
    final id = await _box.add(favoriteHiveObject);

    return tryMapBookmarkHiveObjectToBookmark(favoriteHiveObject)
        .getOrElse((_) => Bookmark.empty)
        .copyWith(id: id);
  }

  @override
  Future<void> removeBookmark(Bookmark favorite) async {
    await _box.delete(favorite.id);
  }

  @override
  Future<void> updateBookmark(Bookmark favorite) async {
    await _box.put(favorite.id, favoriteToHiveObject(favorite));
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

    return Future.wait(futures);
  }

  @override
  Future<void> addBookmarkWithBookmarks(List<Bookmark> bookmarks) {
    final hiveObjects = bookmarks.map(favoriteToHiveObject).toList();
    return _box.addAll(hiveObjects);
  }
}
