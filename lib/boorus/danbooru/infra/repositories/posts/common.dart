// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/functional.dart';
import 'utils.dart';

List<DanbooruPost> parsePost(
  HttpResponse<dynamic> value,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e, urlComposer)).toList();

Either<BooruError, List<DanbooruPost>> tryParseData(
  HttpResponse<dynamic> response,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    Either.tryCatch(
      () => parsePost(
        response,
        urlComposer,
      ),
      (error, stackTrace) => BooruError(
        error: AppError(type: AppErrorType.failedToParseJSON),
      ),
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
      copyrightTags: splitTag(dto.copyrightTags),
      characterTags: splitTag(dto.characterTags),
      artistTags: splitTag(dto.artistTags),
      generalTags: splitTag(dto.generalTags),
      metaTags: splitTag(dto.tagsMeta),
      tags: splitTag(dto.tags),
      width: dto.imageWidth.toDouble(),
      height: dto.imageHeight.toDouble(),
      format: dto.fileExt,
      md5: dto.md5 ?? '',
      lastCommentAt: dto.lastCommentedAt,
      source: dto.source,
      createdAt: dto.createdAt,
      score: dto.score,
      upScore: dto.upScore,
      downScore: dto.downScore,
      favCount: dto.favCount,
      uploaderId: dto.uploaderId,
      rating: mapStringToRating(dto.rating),
      fileSize: dto.fileSize,
      pixivId: dto.pixivId,
      isBanned: dto.isBanned,
      hasChildren: dto.hasChildren,
      parentId: dto.parentId,
      hasLarge: dto.hasLarge ?? false,
    );
  } catch (e) {
    return DanbooruPost.empty();
  }
}
