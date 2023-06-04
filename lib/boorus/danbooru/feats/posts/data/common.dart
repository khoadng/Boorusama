// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/models/utils.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import '../models/danbooru_post.dart';
import '../models/post_variant.dart';
import 'post_dto.dart';
import 'utils.dart';

class ParsePostArguments {
  final HttpResponse<dynamic> value;

  ParsePostArguments(this.value);
}

List<DanbooruPost> _parsePostInIsolate(ParsePostArguments arguments) =>
    parsePost(arguments.value);

Future<List<DanbooruPost>> parsePostAsync(
  HttpResponse<dynamic> value,
) =>
    compute(_parsePostInIsolate, ParsePostArguments(value));

List<DanbooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parseResponse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

TaskEither<BooruError, List<DanbooruPost>> tryParseData(
  HttpResponse<dynamic> response,
) =>
    TaskEither.tryCatch(
      () => parsePostAsync(response),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

// convert a BooruConfig and an orignal tag list to List<String>
List<String> getTags(BooruConfig booruConfig, String tags) {
  final ratingTag = booruFilterConfigToDanbooruTag(booruConfig.ratingFilter);
  final deletedStatusTag = booruConfigDeletedBehaviorToDanbooruTag(
    booruConfig.deletedItemBehavior,
  );
  return [
    ...splitTag(tags),
    if (ratingTag != null) ratingTag,
    if (deletedStatusTag != null) deletedStatusTag,
  ];
}

DanbooruPost postDtoToPost(
  PostDto dto,
) {
  try {
    return DanbooruPost(
      id: dto.id!,
      thumbnailImageUrl: dto.previewFileUrl ?? '',
      sampleImageUrl: dto.largeFileUrl ?? '',
      originalImageUrl: dto.fileUrl ?? '',
      copyrightTags: splitTag(dto.tagStringCopyright),
      characterTags: splitTag(dto.tagStringCharacter),
      artistTags: splitTag(dto.tagStringArtist),
      generalTags: splitTag(dto.tagStringGeneral),
      metaTags: splitTag(dto.tagStringMeta),
      tags: splitTag(dto.tagString),
      width: dto.imageWidth?.toDouble() ?? 0.0,
      height: dto.imageHeight?.toDouble() ?? 0.0,
      format: dto.fileExt ?? 'jpg',
      md5: dto.md5 ?? '',
      lastCommentAt: dto.lastCommentedAt != null
          ? DateTime.parse(dto.lastCommentedAt!)
          : null,
      source: PostSource.from(
        dto.source,
        pixivId: dto.pixivId,
      ),
      createdAt: dto.createdAt != null
          ? DateTime.parse(dto.createdAt!)
          : DateTime.now(),
      score: dto.score ?? 0,
      upScore: dto.upScore ?? 0,
      downScore: dto.downScore ?? 0,
      favCount: dto.favCount ?? 0,
      uploaderId: dto.uploaderId ?? 0,
      rating: mapStringToRating(dto.rating ?? 's'),
      fileSize: dto.fileSize ?? 0,
      isBanned: dto.isBanned ?? false,
      hasChildren: dto.hasChildren ?? false,
      parentId: dto.parentId,
      hasLarge: dto.hasLarge ?? false,
      duration: dto.mediaAsset?.duration ?? 0,
      variants:
          dto.mediaAsset?.variants?.map(variantDtoToVariant).toList() ?? [],
    );
  } catch (e) {
    return DanbooruPost.empty();
  }
}

PostVariant variantDtoToVariant(VariantDto dto) => PostVariant(
      url: dto.url ?? '',
      width: dto.width ?? 0,
      height: dto.height ?? 0,
      type: mapStringToPostQualityType(dto.type),
      fileExt: dto.fileExt ?? 'jpg',
    );
