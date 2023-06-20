// Package imports:
import 'package:collection/collection.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/booru_config.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'e621_parser.dart';
import 'e621_post.dart';
import 'e621_post_dto.dart';

typedef E621PostsOrError = PostsOrErrorCore<E621Post>;

abstract class E621PostRepository implements PostRepository {
  E621PostsOrError getPosts(String tags, int page, {int? limit});
}

class E621PostRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements E621PostRepository {
  E621PostRepositoryApi(
    this.api,
    this.booruConfig,
    this.settingsRepository,
    this.blacklistedTagRepository, {
    required this.onFetch,
  });

  final E621Api api;
  final BooruConfig booruConfig;
  final void Function(List<E621Post> posts) onFetch;

  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  final Cache<List<E621Post>> _cache = Cache(
    maxCapacity: 5,
    staleDuration: const Duration(seconds: 10),
  );

  String _buildKey(String tags, int page, int? limit) => '$tags-$page-$limit';

  @override
  PostsOrError getPostsFromTags(String tags, int page, {int? limit}) =>
      getPosts(tags, page, limit: limit);

  @override
  E621PostsOrError getPosts(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        final key = _buildKey(tags, page, limit);
        final cached = _cache.get(key);

        if (cached != null && cached.isNotEmpty) {
          return cached;
        }

        final response = await $(
          tryParseResponse(
            fetcher: () => getPostsPerPage().then((lim) => api.getPosts(
                  booruConfig.login,
                  booruConfig.apiKey,
                  page,
                  //FIXME: should apply config tags here
                  tags,
                  limit ?? lim,
                )),
          ),
        );

        final data = await $(tryParseData(response));

        final filtered = await $(tryFilterBlacklistedTags(data));

        onFetch.call(filtered);

        _cache.set(key, filtered);

        return filtered;
      });
}

E621Post postDtoToPost(E621PostDto dto) {
  final videoUrl = extractSampleVideoUrl(dto);
  final format = videoUrl.isNotEmpty ? extension(videoUrl).substring(1) : '';

  return E621Post(
    id: dto.id ?? 0,
    source: PostSource.from(dto.sources?.firstOrNull),
    thumbnailImageUrl: dto.preview?.url ?? '',
    sampleImageUrl: dto.sample?.url ?? '',
    originalImageUrl: dto.file?.url ?? '',
    rating: mapStringToRating(dto.rating),
    hasComment: dto.commentCount != null && dto.commentCount! > 0,
    isTranslated: dto.hasNotes ?? false,
    hasParentOrChildren: dto.relationships?.hasChildren ??
        false || dto.relationships?.parentId != null,
    format: format.isEmpty ? dto.file?.ext ?? '' : format,
    videoUrl: videoUrl,
    width: dto.file?.width?.toDouble() ?? 0,
    height: dto.file?.height?.toDouble() ?? 0,
    md5: dto.file?.md5 ?? '',
    fileSize: dto.file?.size ?? 0,
    score: dto.score?.total ?? 0,
    createdAt: DateTime.parse(dto.createdAt ?? ''),
    duration: dto.duration ?? 0,
    characterTags: List<String>.from(dto.tags?['character'] ?? []).toList(),
    copyrightTags: List<String>.from(dto.tags?['copyright'] ?? []).toList(),
    artistTags: List<String>.from(dto.tags?['artist'] ?? []).toList(),
    generalTags: List<String>.from(dto.tags?['general'] ?? []).toList(),
    metaTags: List<String>.from(dto.tags?['meta'] ?? []).toList(),
    speciesTags: List<String>.from(dto.tags?['species'] ?? []).toList(),
    loreTags: List<String>.from(dto.tags?['lore'] ?? []).toList(),
    invalidTags: List<String>.from(dto.tags?['invalid'] ?? []).toList(),
    upScore: dto.score?.up ?? 0,
    downScore: dto.score?.down ?? 0,
    favCount: dto.favCount ?? 0,
    isFavorited: dto.isFavorited ?? false,
    sources: dto.sources?.map(PostSource.from).toList() ?? [],
    description: dto.description ?? '',
  );
}

String extractSampleVideoUrl(E621PostDto dto) {
  final p720 = dto.sample?.alternates?['720p']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  final p480 = dto.sample?.alternates?['480p']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  final pOriginal = dto.sample?.alternates?['original']?.urls
          ?.firstWhereOrNull((e) => e.endsWith('.mp4')) ??
      '';

  return p720.isNotEmpty
      ? p720
      : p480.isNotEmpty
          ? p480
          : pOriginal;
}
