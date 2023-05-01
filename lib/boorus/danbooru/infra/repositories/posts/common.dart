// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/functional.dart';
import 'utils.dart';

typedef DataFetcher = Future<HttpResponse<dynamic>> Function();

TaskEither<BooruError, BooruConfig> getBooruConfigFrom(
        CurrentBooruConfigRepository configRepository) =>
    TaskEither.tryCatch(
      () => configRepository.get(),
      (error, stackTrace) => BooruError(
          error: AppError(type: AppErrorType.failedToLoadBooruConfig)),
    ).flatMap((r) => r == null
        ? TaskEither.left(
            BooruError(error: AppError(type: AppErrorType.booruConfigNotFound)),
          )
        : TaskEither.right(r));

TaskEither<BooruError, HttpResponse<dynamic>> getData({
  required DataFetcher fetcher,
}) =>
    TaskEither.tryCatch(
      () => fetcher(),
      (error, stackTrace) => error is DioError
          ? BooruError(
              error: error.response
                  .toEither(
                      () => AppError(type: AppErrorType.cannotReachServer))
                  .map((response) => ServerError(
                        httpStatusCode: response.statusCode,
                      )))
          : BooruError(
              error: AppError(type: AppErrorType.loadDataFromServerFailed)),
    );

List<DanbooruPost> parsePost(
  HttpResponse<dynamic> value,
  ImageSourceComposer<PostDto> urlComposer,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e, urlComposer)).where(isPostValid).toList();

Either<BooruError, List<DanbooruPost>> parseData(
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
