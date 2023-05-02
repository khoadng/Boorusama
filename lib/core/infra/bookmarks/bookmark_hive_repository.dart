// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';

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
    return favoriteHiveObjectToFavorite(favoriteHiveObject);
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
  Future<List<Bookmark>> getAllBookmarks() async {
    return _box.values
        .map((hiveObject) => favoriteHiveObjectToFavorite(hiveObject))
        .toList();
  }
}

Bookmark favoriteHiveObjectToFavorite(BookmarkHiveObject hiveObject) {
  return Bookmark(
    id: hiveObject.key,
    booruId: hiveObject.booruId!,
    createdAt: hiveObject.createdAt!,
    updatedAt: hiveObject.updatedAt!,
    thumbnailUrl: hiveObject.thumbnailUrl!,
    sampleUrl: hiveObject.sampleUrl!,
    originalUrl: hiveObject.originalUrl!,
    sourceUrl: hiveObject.sourceUrl!,
    width: hiveObject.width!,
    height: hiveObject.height!,
    md5: hiveObject.md5!,
  );
}

BookmarkHiveObject favoriteToHiveObject(Bookmark favorite) {
  return BookmarkHiveObject(
    booruId: favorite.booruId,
    createdAt: favorite.createdAt,
    updatedAt: favorite.updatedAt,
    thumbnailUrl: favorite.thumbnailUrl,
    sampleUrl: favorite.sampleUrl,
    originalUrl: favorite.originalUrl,
    sourceUrl: favorite.sourceUrl,
    width: favorite.width,
    height: favorite.height,
    md5: favorite.md5,
  );
}
