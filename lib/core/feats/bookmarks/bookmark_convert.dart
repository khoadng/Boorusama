// Project imports:
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/path.dart';
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
                realSourceUrl: hiveObject.realSourceUrl,
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
        realSourceUrl: hiveObject.realSourceUrl,
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
    realSourceUrl: bookmark.realSourceUrl,
  );
}

class BookmarkPost extends SimplePost {
  BookmarkPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.getLink,
    required super.uploaderId,
    required this.realSourceUrl,
  });

  final PostSource realSourceUrl;
}

extension BookmarkToPost on Bookmark {
  BookmarkPost toPost() => BookmarkPost(
        id: id,
        thumbnailImageUrl: thumbnailUrl,
        sampleImageUrl: sampleUrl,
        originalImageUrl: originalUrl,
        tags: tags,
        rating: Rating.unknown,
        hasComment: false,
        isTranslated: false,
        hasParentOrChildren: false,
        source: PostSource.from(sourceUrl),
        score: 0,
        duration: 0,
        fileSize: 0,
        format: extension(originalUrl),
        hasSound: null,
        height: height,
        md5: md5,
        videoThumbnailUrl: thumbnailUrl,
        videoUrl: originalUrl,
        width: width,
        getLink: (_) => sourceUrl,
        uploaderId: null,
        realSourceUrl: PostSource.from(realSourceUrl),
      );
}

extension PostToBookmark on Post {
  Bookmark toBookmark() => Bookmark(
        id: id,
        booruId: -1,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: createdAt ?? DateTime.now(),
        thumbnailUrl: thumbnailImageUrl,
        sampleUrl: sampleImageUrl,
        originalUrl: originalImageUrl,
        sourceUrl: '',
        width: width,
        height: height,
        md5: md5,
        tags: tags,
        realSourceUrl: source.url,
      );
}
