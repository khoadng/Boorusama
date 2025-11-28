// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/path.dart';
import '../../../posts/position/types.dart';
import '../../../posts/post/types.dart';
import '../../../posts/rating/types.dart';
import '../../../posts/sources/types.dart';
import '../types/bookmark.dart';
import 'hive/bookmark_hive_object.dart';

BookmarkGetError mapBoxErrorToBookmarkGetError(BoxError error) =>
    switch (error) {
      BoxError.boxClosed => BookmarkGetError.databaseClosed,
      BoxError.unknown => BookmarkGetError.unknown,
    };

Either<BookmarkGetError, List<Bookmark>> tryMapBookmarkHiveObjectsToBookmarks(
  Iterable<BookmarkHiveObject> hiveObjects,
  ImageUrlResolver Function(int? booruId) imageUrlResolver,
) => Either.tryCatch(
  () => hiveObjects
      .map(
        (hiveObject) => Bookmark(
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
          tags: hiveObject.tags?.toSet() ?? {},
          realSourceUrl: hiveObject.realSourceUrl,
          format: hiveObject.format,
          imageUrlResolver: imageUrlResolver(hiveObject.booruId),
          postId: hiveObject.postId,
          metadata: hiveObject.metadata ?? {},
        ),
      )
      .toList(),
  (o, s) {
    return BookmarkGetError.nullField;
  },
);

Either<BookmarkGetError, Bookmark> tryMapBookmarkHiveObjectToBookmark(
  BookmarkHiveObject hiveObject,
  ImageUrlResolver Function(int? booruId) imageUrlResolver,
) => Either.tryCatch(
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
    tags: hiveObject.tags?.toSet() ?? {},
    realSourceUrl: hiveObject.realSourceUrl,
    format: hiveObject.format,
    imageUrlResolver: imageUrlResolver(hiveObject.booruId),
    postId: hiveObject.postId,
    metadata: hiveObject.metadata ?? {},
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
    tags: bookmark.tags.toList(),
    realSourceUrl: bookmark.realSourceUrl,
    format: bookmark.format,
    postId: bookmark.postId,
    metadata: bookmark.metadata,
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
    required super.uploaderId,
    required this.realSourceUrl,
    required super.metadata,
    required this.bookmark,
    required this.originalPostId,
  });

  final PostSource realSourceUrl;
  final Bookmark bookmark;
  final int? originalPostId;

  Post toOriginalPost() {
    return bookmark.toPost(
      overridePostId: originalPostId,
    );
  }

  PaginationSnapshot? toPaginationSnapshot() => switch (bookmark.postId) {
    (final postId?) => PaginationSnapshot(
      targetId: postId,
      tags: bookmark.metadataSearch ?? '',
      historicalPage: bookmark.metadataPage,
      historicalChunkSize: bookmark.metadataLimit,
      timestamp: bookmark.createdAt,
    ),
    _ => null,
  };
}

extension BookmarkToPost on Bookmark {
  BookmarkPost toPost({
    int? overridePostId,
  }) => BookmarkPost(
    id: overridePostId ?? id,
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
    format: format ?? extension(originalUrl),
    hasSound: null,
    height: height,
    md5: md5,
    videoThumbnailUrl: thumbnailUrl,
    videoUrl: originalUrl,
    width: width,
    uploaderId: null,
    realSourceUrl: PostSource.from(realSourceUrl),
    metadata: null,
    bookmark: this,
    originalPostId: postId,
  );
}
