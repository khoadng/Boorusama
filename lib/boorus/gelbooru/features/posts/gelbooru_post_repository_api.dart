// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path/path.dart' as path;
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru/features/posts/gelbooru_post.dart';
import 'package:boorusama/boorus/gelbooru/features/tags/utils.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'post_dto.dart';

class ParsePostArguments {
  final HttpResponse<dynamic> value;

  ParsePostArguments(this.value);
}

List<Post> parsePost(HttpResponse<dynamic> value) {
  final dtos = <PostDto>[];
  dynamic data;
  try {
    data = value.response.data['post'];
    if (data == null) return [];
  } catch (e) {
    return [];
  }

  for (final item in data) {
    dtos.add(PostDto.fromJson(item));
  }

  return dtos.map((e) {
    return postDtoToPost(e);
  }).toList();
}

List<Post> _parsePostInIsolate(ParsePostArguments arguments) =>
    parsePost(arguments.value);

Future<List<Post>> parsePostAsync(HttpResponse<dynamic> value) =>
    compute(_parsePostInIsolate, ParsePostArguments(value));

TaskEither<BooruError, List<Post>> tryParsePosts(
        HttpResponse<dynamic> response) =>
    TaskEither.tryCatch(
      () => parsePostAsync(response),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

class GelbooruPostRepositoryApi
    with GlobalBlacklistedTagFilterMixin, SettingsRepositoryMixin
    implements PostRepository {
  const GelbooruPostRepositoryApi({
    required this.api,
    required this.booruConfig,
    required this.blacklistedTagRepository,
    required this.settingsRepository,
  });

  final GelbooruApi api;
  final BooruConfig booruConfig;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  @override
  final SettingsRepository settingsRepository;

  List<String> getTags(BooruConfig config, String tags) {
    final tag = booruFilterConfigToGelbooruTag(config.ratingFilter);

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
      tryParseResponse(
        fetcher: () => api.getPosts(
          booruConfig.apiKey,
          booruConfig.login,
          'dapi',
          'post',
          'index',
          getTags(booruConfig, tags).join(' '),
          '1',
          (page - 1).toString(),
        ),
      ).flatMap(tryParsePosts).flatMap(tryFilterBlacklistedTags);
}

Post postDtoToPost(PostDto dto) {
  return GelbooruPost(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags?.split(' ').toList() ?? [],
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.image ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: mapStringToRating(dto.rating ?? 'general'),
    md5: dto.md5 ?? '',
    hasComment: _boolFromString(dto.hasComments),
    hasParentOrChildren: _boolFromString(dto.hasChildren) ||
        (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
    score: dto.score ?? 0,
  );
}

bool _boolFromString(String? value) {
  if (value == null) return false;
  if (value == 'false') return false;
  if (value == 'true') return true;

  return false;
}
