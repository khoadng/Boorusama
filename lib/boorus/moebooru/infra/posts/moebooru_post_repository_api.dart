// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/posts/moebooru_post.dart';
import 'package:boorusama/boorus/moebooru/domain/utils.dart';
import 'package:boorusama/boorus/moebooru/infra/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'package:boorusama/functional.dart';

class ParseMoebooruPostArguments {
  final HttpResponse<dynamic> value;

  ParseMoebooruPostArguments(this.value);
}

List<MoebooruPost> _parseMoebooruPostInIsolate(
        ParseMoebooruPostArguments arguments) =>
    parsePost(arguments.value);

Future<List<MoebooruPost>> parsePostAsync(HttpResponse<dynamic> value) =>
    compute(_parseMoebooruPostInIsolate, ParseMoebooruPostArguments(value));

List<MoebooruPost> parsePost(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => PostDto.fromJson(item),
    ).map((e) => postDtoToPost(e)).toList();

TaskEither<BooruError, List<MoebooruPost>> tryParsePosts(
        HttpResponse<dynamic> response) =>
    TaskEither.tryCatch(
      () => parsePostAsync(response),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

class MoebooruPostRepositoryApi
    with
        BlacklistedTagFilterMixin,
        CurrentBooruConfigRepositoryMixin,
        SettingsRepositoryMixin
    implements PostRepository {
  MoebooruPostRepositoryApi(
    this._api,
    this.blacklistedTagRepository,
    this.currentBooruConfigRepository,
    this.settingsRepository,
  );

  final MoebooruApi _api;
  @override
  final BlacklistedTagRepository blacklistedTagRepository;
  @override
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  @override
  final SettingsRepository settingsRepository;

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
                fetcher: () => getPostsPerPage().then((lim) => _api.getPosts(
                      config.login,
                      config.apiKey,
                      page,
                      getTags(config, tags).join(' '),
                      limit ?? lim,
                    )),
              ))
          .flatMap(tryParsePosts)
          .flatMap(tryFilterBlacklistedTags);
}

MoebooruPost postDtoToPost(PostDto postDto) {
  return MoebooruPost(
    id: postDto.id ?? 0,
    thumbnailImageUrl: postDto.previewUrl ?? '',
    sampleImageUrl: postDto.sampleUrl ?? '',
    originalImageUrl: postDto.fileUrl ?? '',
    tags: postDto.tags != null ? postDto.tags!.split(' ') : [],
    source: PostSource.from(postDto.source),
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
