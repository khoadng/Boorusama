// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:path/path.dart' as path;
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_v0.2_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/gelbooru_post.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/utils.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

List<GelbooruPost> _parsePostInIsolate(
  HttpResponse<dynamic> value,
  String baseUrl,
) {
  final posts = <GelbooruPost>[];

  if (value.data == null) return [];

  final data = value.data;

  if (data is String) {
    final List<dynamic> json = jsonDecode(data);

    for (final post in json) {
      posts.add(_dynamicDataToPost(post, baseUrl));
    }

    return posts;
  } else if (data is List<dynamic>) {
    for (final post in data) {
      posts.add(_dynamicDataToPost(post, baseUrl));
    }

    return posts;
  } else {
    throw Exception('Unknown data type');
  }
}

class GelbooruV0Dot2PostRepositoryApi
    with SettingsRepositoryMixin
    implements PostRepository {
  const GelbooruV0Dot2PostRepositoryApi({
    required this.baseUrl,
    required this.api,
    required this.booruConfig,
    required this.settingsRepository,
  });

  final String baseUrl;
  final GelbooruV0dot2Api api;
  final BooruConfig booruConfig;
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
      TaskEither.Do(($) async {
        final lim = await getPostsPerPage();
        final response = await $(tryParseResponse(
          fetcher: () => api.getPosts(
            booruConfig.apiKey,
            booruConfig.login,
            'dapi',
            'post',
            'index',
            getTags(booruConfig, tags).join(' '),
            '1',
            (page - 1).toString(),
            limit: limit ?? lim,
          ),
        ));

        final data = await $(tryParseJsonFromResponse(response, baseUrl));

        return data;
      });
}

// I'm lazy to write a parser for this, the current implementation is way too complicated
TaskEither<BooruError, List<GelbooruPost>> tryParseJsonFromResponse<T>(
  HttpResponse<dynamic> response,
  String baseUrl,
) =>
    TaskEither.tryCatch(
      () => Future.value(_parsePostInIsolate(response, baseUrl)),
      (error, stackTrace) => AppError(type: AppErrorType.failedToParseJSON),
    );

GelbooruPost _dynamicDataToPost(Map<String, dynamic> data, String baseUrl) {
  var thumbnailUrl = '';
  var sampleUrl = '';
  var originalUrl = '';

  if (data['preview_url'] != null) {
    thumbnailUrl = data['preview_url'];
  } else if (data['directory'] != null && data['image'] != null) {
    thumbnailUrl =
        '$baseUrl/thumbnails/${data['directory']}/thumbnail_${data['image']}';
    // Change the extension to jpg
    thumbnailUrl = thumbnailUrl.replaceAll(
      path.extension(thumbnailUrl),
      '.jpg',
    );
  } else {
    thumbnailUrl = '';
  }

  if (data['file_url'] != null) {
    originalUrl = data['file_url'];
  } else if (data['directory'] != null && data['image'] != null) {
    originalUrl = '$baseUrl/images/${data['directory']}/${data['image']}';
  } else {
    originalUrl = '';
  }

  if (data['sample_url'] != null) {
    sampleUrl = data['sample_url'];
  } else if (data['directory'] != null && data['image'] != null) {
    if (data['sample'] != null && data['sample'] == true) {
      sampleUrl =
          '$baseUrl/samples/${data['directory']}/sample_${data['image']}';
      // Change the extension to jpg
      sampleUrl = sampleUrl.replaceAll(
        path.extension(sampleUrl),
        '.jpg',
      );
    } else {
      sampleUrl = originalUrl;
    }
  } else {
    sampleUrl = '';
  }

  return GelbooruPost(
    id: data['id'] ?? 0,
    thumbnailImageUrl: thumbnailUrl,
    sampleImageUrl: sampleUrl,
    originalImageUrl: originalUrl,
    tags: data['tags']?.split(' ').toList() ?? [],
    width: data['width']?.toDouble() ?? 0,
    height: data['height']?.toDouble() ?? 0,
    format: path.extension(data['image'] ?? 'foo.png').substring(1),
    source: PostSource.from(data['source']),
    rating: mapStringToRating(data['rating'] ?? 'general'),
    md5: data['hash'] ?? '',
    hasComment: _parseHasComment(data),
    hasParentOrChildren: (data['parent_id'] != null && data['parent_id'] != 0),
    fileSize: 0,
    score: data['score'] ?? 0,
    createdAt: null,
    parentId: data['parent_id'],
  );
}

bool _parseHasComment(Map<String, dynamic> data) {
  if (data['has_comments'] != null) {
    final value = data['has_comments'];
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value > 0;
    } else if (value is String) {
      return bool.tryParse(value) ?? false;
    } else {
      return false;
    }
  } else if (data['comment_count'] != null) {
    final value = data['comment_count'];
    if (value is int) {
      return value > 0;
    } else if (value is String) {
      final intValue = int.tryParse(value);
      return intValue != null ? intValue > 0 : false;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
