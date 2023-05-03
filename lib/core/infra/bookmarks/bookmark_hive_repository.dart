// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';
import 'package:boorusama/functional.dart';
import 'bookmark_convert.dart';

class BookmarkHiveRepository implements BookmarkRepository {
  const BookmarkHiveRepository(this._box);

  final Box<BookmarkHiveObject> _box;

  @override
  Future<Bookmark> addBookmark(Booru booru, Post post) async {
    final favoriteHiveObject = BookmarkHiveObject(
      booruId: booru.booruType.index,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      thumbnailUrl: post.thumbnailImageUrl,
      sampleUrl: post.sampleImageUrl,
      originalUrl: post.originalImageUrl,
      sourceUrl: post.getLink(booru.url),
      width: post.width,
      height: post.height,
      md5: post.md5,
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
}
