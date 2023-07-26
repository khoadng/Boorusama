// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/foundation/loggers/logger.dart';
import 'package:boorusama/functional.dart';
import 'common.dart';
import 'danbooru_post.dart';
import 'danbooru_post_repository.dart';

class PostRepositoryApi
    with SettingsRepositoryMixin, LoggerMixin
    implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    this.booruConfig,
    this.settingsRepository,
    this.logger,
  ) : _api = api;

  final BooruConfig booruConfig;
  final DanbooruApi _api;
  @override
  final SettingsRepository settingsRepository;
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

        final data = await $(tryParseJsonFromResponse(response, parsePost));

        _cache.set(key, data);

        return data;
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
