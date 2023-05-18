// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'common.dart';

class PostRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    CurrentBooruConfigRepository currentBooruConfigRepository,
    this.settingsRepository,
    this.blacklistedTagRepository,
  )   : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;
  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;

  @override
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      tryGetBooruConfigFrom(_currentUserBooruRepository)
          .flatMap(
            (booruConfig) => tryParseResponse(
              fetcher: () => getPostsPerPage().then((lim) => _api.getPosts(
                    booruConfig.login,
                    booruConfig.apiKey,
                    page,
                    getTags(booruConfig, tags).join(' '),
                    limit ?? lim,
                  )),
            ),
          )
          .flatMap((response) => tryParseData(response))
          .flatMap(tryFilterBlacklistedTags);

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
