// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/benchmark.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/foundation/loggers/logger.dart';
import 'package:boorusama/functional.dart';
import '../models/danbooru_post.dart';
import '../models/danbooru_post_repository.dart';
import 'common.dart';

class PostRepositoryApi
    with
        SettingsRepositoryMixin,
        GlobalBlacklistedTagFilterMixin,
        LoggerMixin,
        BenchmarkMixin
    implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    this.booruConfig,
    this.settingsRepository,
    this.blacklistedTagRepository,
    this.logger,
  ) : _api = api;

  final BooruConfig booruConfig;
  final DanbooruApi _api;
  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  final Cache<List<DanbooruPost>> _cache = Cache(
    maxCapacity: 5,
    staleDuration: const Duration(seconds: 10),
  );
  @override
  final LoggerService logger;

  String _buildKey(String tags, int page) => '$tags-$page';

  @override
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final key = _buildKey(tags, page);
        final cached = _cache.get(key);

        if (cached != null && cached.isNotEmpty) {
          return cached;
        }

        final response = await $(
          tryParseResponse(
            fetcher: () => getPostsPerPage().then((lim) => _api.getPosts(
                  page,
                  getTags(booruConfig, tags).join(' '),
                  limit ?? lim,
                )),
          ),
        );

        final data = await benchmark(
          () => $(tryParseJsonFromResponse(response, parsePost)),
          onResult: (elapsed) => logI(
            'Performance',
            'Parse data for ($tags, $page, limit: $limit) took ${elapsed.inMilliseconds}ms',
          ),
        );

        final filtered = await $(tryFilterBlacklistedTags(data));

        _cache.set(key, filtered);

        return filtered;
      });

  @override
  DanbooruPostsOrError getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      getPosts(tags, page, limit: limit);
}
