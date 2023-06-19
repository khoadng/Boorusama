// Package imports:
import 'package:collection/collection.dart';

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
    format: dto.file?.ext ?? '',
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
    upScore: dto.score?.up ?? 0,
    downScore: dto.score?.down ?? 0,
    favCount: dto.favCount ?? 0,
    isFavorited: dto.isFavorited ?? false,
    sources: dto.sources?.map(PostSource.from).toList() ?? [],
    description: dto.description ?? '',
  );
}
