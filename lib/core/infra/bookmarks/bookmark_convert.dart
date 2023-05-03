// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';
import 'package:boorusama/functional.dart';

// map BoxError to BookmarkGetError
BookmarkGetError mapBoxErrorToBookmarkGetError(BoxError error) {
  switch (error) {
    case BoxError.boxClosed:
      return BookmarkGetError.databaseClosed;
    case BoxError.unknown:
      return BookmarkGetError.unknown;
  }
}

Either<BookmarkGetError, List<Bookmark>> tryMapBookmarkHiveObjectsToBookmarks(
  Iterable<BookmarkHiveObject> hiveObjects,
) =>
    Either.tryCatch(
      () => hiveObjects
          .map((hiveObject) => Bookmark(
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
              ))
          .toList(),
      (o, s) {
        return BookmarkGetError.nullField;
      },
    );

// map BookmarkHiveObject to Bookmark
Either<BookmarkGetError, Bookmark> tryMapBookmarkHiveObjectToBookmark(
  BookmarkHiveObject hiveObject,
) =>
    Either.tryCatch(
      () => Bookmark(
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
      ),
      (o, s) => BookmarkGetError.nullField,
    );

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
