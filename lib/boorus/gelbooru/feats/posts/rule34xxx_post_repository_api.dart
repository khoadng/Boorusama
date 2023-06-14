// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path/path.dart' as path;
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/rule34xxx/rule34xxx_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/gelbooru_post.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/utils.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';
import 'rule34xxx_post_dto.dart';

List<GelbooruPost> _parsePostInIsolate(HttpResponse<dynamic> value) {
  final dtos = <Rule34xxxPostDto>[];

  for (final item in value.data) {
    dtos.add(Rule34xxxPostDto.fromJson(item));
  }

  return dtos.map((e) => _postDtoToPost(e)).toList();
}

Future<List<GelbooruPost>> _parsePostAsync(HttpResponse<dynamic> value) =>
    compute(_parsePostInIsolate, value);

TaskEither<BooruError, List<GelbooruPost>> _tryParsePosts(
        HttpResponse<dynamic> response) =>
    TaskEither.tryCatch(
      () => _parsePostAsync(response),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

class Rule34xxxPostRepositoryApi
    with GlobalBlacklistedTagFilterMixin, SettingsRepositoryMixin
    implements PostRepository {
  const Rule34xxxPostRepositoryApi({
    required this.api,
    required this.booruConfig,
    required this.blacklistedTagRepository,
    required this.settingsRepository,
  });

  final Rule34xxxApi api;
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
      ).flatMap(_tryParsePosts).flatMap(tryFilterBlacklistedTags);
}

GelbooruPost _postDtoToPost(Rule34xxxPostDto dto) {
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
    md5: dto.hash ?? '',
    hasComment: dto.commentCount != null ? dto.commentCount! > 0 : false,
    hasParentOrChildren: (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
    score: dto.score ?? 0,
    createdAt: null,
  );
}
