// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_variant.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/functional.dart';
import 'utils.dart';

class ParsePostArguments {
  final HttpResponse<dynamic> value;
  final ImageSourceComposer<PostDto> urlComposer;

  ParsePostArguments(this.value, this.urlComposer);
}

List<DanbooruPost> _parsePostInIsolate(ParsePostArguments arguments) =>
    parsePost(arguments.value, arguments.urlComposer);

Future<List<DanbooruPost>> parsePostAsync(
  HttpResponse<dynamic> value,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    compute(_parsePostInIsolate, ParsePostArguments(value, urlComposer));

List<DanbooruPost> parsePost(
  HttpResponse<dynamic> value,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e, urlComposer)).toList();

TaskEither<BooruError, List<DanbooruPost>> tryParseData(
  HttpResponse<dynamic> response,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    TaskEither.tryCatch(
      () => parsePostAsync(response, urlComposer),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

DanbooruPost postDtoToPost(
  PostDto dto,
  ImageSourceComposer<PostDto> urlComposer,
) {
  try {
    final sources = urlComposer.compose(dto);

    return DanbooruPost(
      id: dto.id!,
      thumbnailImageUrl: sources.thumbnail,
      sampleImageUrl: sources.sample,
      originalImageUrl: sources.original,
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
      pixivId: dto.pixivId,
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
