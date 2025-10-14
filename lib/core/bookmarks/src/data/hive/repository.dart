// Package imports:
import 'package:foundation/foundation.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../posts/post/types.dart';
import '../../../../posts/sources/types.dart';
import '../../types/bookmark.dart';
import '../../types/bookmark_repository.dart';
import '../bookmark_convert.dart';
import 'bookmark_hive_object.dart';

class BookmarkHiveRepository implements BookmarkRepository {
  const BookmarkHiveRepository(this._box);

  final Box<BookmarkHiveObject> _box;

  @override
  Future<Bookmark> addBookmark(
    int booruId,
    Post post, {
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
    required PostLinkGenerator Function(int? booruId) postLinkGenerator,
  }) async {
    final now = DateTime.now();

    final favoriteHiveObject = BookmarkHiveObject(
      booruId: booruId,
      postId: post.id,
      createdAt: now,
      updatedAt: now,
      thumbnailUrl: post.thumbnailImageUrl,
      sampleUrl: post.sampleImageUrl,
      originalUrl: post.originalImageUrl,
      sourceUrl: postLinkGenerator(booruId).getLink(post),
      width: post.width,
      height: post.height,
      md5: post.md5,
      tags: post.tags.toList(),
      realSourceUrl: post.source.url,
      format: post.format,
      metadata: Bookmark.toMetadata(post.metadata),
    );
    final id = await _box.add(favoriteHiveObject);

    return tryMapBookmarkHiveObjectToBookmark(
      favoriteHiveObject,
      imageUrlResolver,
    ).getOrElse((_) => Bookmark.empty).copyWith(id: id);
  }

  @override
  Future<void> removeBookmark(Bookmark favorite) async {
    await _box.delete(favorite.id);
  }

  @override
  Future<void> removeBookmarks(Iterable<Bookmark> favorites) async {
    await _box.deleteAll(favorites.map((favorite) => favorite.id));
  }

  @override
  Future<void> updateBookmark(Bookmark favorite) async {
    await _box.put(favorite.id, favoriteToHiveObject(favorite));
  }

  @override
  BookmarksOrError getAllBookmarks({
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
  }) =>
      TaskEither.fromEither(
        tryGetBoxValues(_box).mapLeft(mapBoxErrorToBookmarkGetError),
      ).flatMap(
        (objects) => TaskEither.fromEither(
          tryMapBookmarkHiveObjectsToBookmarks(objects, imageUrlResolver),
        ),
      );

  @override
  Future<List<Bookmark>> addBookmarks(
    int booruId,
    Iterable<Post> posts, {
    required ImageUrlResolver Function(int? booruId) imageUrlResolver,
    required PostLinkGenerator Function(int? booruId) postLinkGenerator,
  }) {
    final futures = posts.map(
      (post) => addBookmark(
        booruId,
        post,
        imageUrlResolver: imageUrlResolver,
        postLinkGenerator: postLinkGenerator,
      ),
    );

    return Future.wait(futures);
  }

  @override
  Future<void> addBookmarkWithBookmarks(List<Bookmark> bookmarks) {
    final hiveObjects = bookmarks.map(favoriteToHiveObject).toList();
    return _box.addAll(hiveObjects);
  }
}
