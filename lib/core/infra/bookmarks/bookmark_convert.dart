// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/infra/bookmarks/bookmark_hive_object.dart';
import 'package:boorusama/functional.dart';

// map BoxError to BookmarkGetError
BookmarkGetError mapBoxErrorToBookmarkGetError(BoxError error) =>
    switch (error) {
      BoxError.boxClosed => BookmarkGetError.databaseClosed,
      BoxError.unknown => BookmarkGetError.unknown
    };

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
                tags: hiveObject.tags ?? [],
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
        tags: hiveObject.tags ?? [],
      ),
      (o, s) => BookmarkGetError.nullField,
    );

BookmarkHiveObject favoriteToHiveObject(Bookmark bookmark) {
  return BookmarkHiveObject(
    booruId: bookmark.booruId,
    createdAt: bookmark.createdAt,
    updatedAt: bookmark.updatedAt,
    thumbnailUrl: bookmark.thumbnailUrl,
    sampleUrl: bookmark.sampleUrl,
    originalUrl: bookmark.originalUrl,
    sourceUrl: bookmark.sourceUrl,
    width: bookmark.width,
    height: bookmark.height,
    md5: bookmark.md5,
    tags: bookmark.tags,
  );
}
