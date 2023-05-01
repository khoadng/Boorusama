// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_post.dart';
import 'package:boorusama/boorus/moebooru/domain/utils.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/core/application/posts/filter.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'package:boorusama/functional.dart';

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

Either<BooruError, List<MoebooruPost>> tryParsePosts(
        HttpResponse<dynamic> response) =>
    Either.tryCatch(
      () => parsePost(response),
      (error, stackTrace) =>
          BooruError(error: AppError(type: AppErrorType.failedToParseJSON)),
    );

class MoebooruPostRepositoryApi
    with BlacklistedTagFilterMixin, CurrentBooruConfigRepositoryMixin
    implements PostRepository {
  MoebooruPostRepositoryApi(
    this._api,
    this.blacklistedTagRepository,
    this.currentBooruConfigRepository,
  );

  final MoebooruApi _api;
  @override
  final BlacklistedTagRepository blacklistedTagRepository;
  @override
  final CurrentBooruConfigRepository currentBooruConfigRepository;

  List<String> getTags(BooruConfig config, String tags) {
    final tag = booruFilterConfigToMoebooruTag(config.ratingFilter);

    return [
      ...tags.split(' '),
      if (tag != null) tag,
    ];
  }

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      tryGetBooruConfig()
          .flatMap((config) => tryParseResponse(
                fetcher: () => _api.getPosts(
                  config.login,
                  config.apiKey,
                  page,
                  getTags(config, tags).join(' '),
                  limit ?? 60,
                ),
              ))
          .flatMap((response) => TaskEither.fromEither(tryParsePosts(response)))
          .flatMap(tryFilterBlacklistedTags);
}

MoebooruPost postDtoToPost(PostDto postDto) {
  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    sampleLargeImageUrl: postDto.jpegUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags != null ? postDto.tags!.split(' ') : [],
    source: postDto.source,
    rating: mapStringToRating(postDto.rating ?? ''),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: postDto.hasChildren ?? false,
    downloadUrl: postDto.fileUrl ?? '',
    width: postDto.width!.toDouble(),
    height: postDto.height!.toDouble(),
    md5: postDto.md5 ?? '',
    fileSize: postDto.fileSize ?? 0,
    format: postDto.fileUrl?.split('.').last ?? '',
  );
}
