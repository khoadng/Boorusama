// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/cache_mixin.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'package:boorusama/functional.dart';
import 'common.dart';

class PostRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    this.booruConfig,
    this.settingsRepository,
    this.blacklistedTagRepository,
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
                  booruConfig.login,
                  booruConfig.apiKey,
                  page,
                  getTags(booruConfig, tags).join(' '),
                  limit ?? lim,
                )),
          ),
        );

        final data = await $(tryParseData(response));

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
