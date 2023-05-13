// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/utils.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/networks.dart';
import 'common.dart';
import 'utils.dart';

class PostRepositoryApi
    with SettingsRepositoryMixin
    implements DanbooruPostRepository {
  PostRepositoryApi(
    DanbooruApi api,
    CurrentBooruConfigRepository currentBooruConfigRepository,
    this.settingsRepository,
  )   : _api = api,
        _currentUserBooruRepository = currentBooruConfigRepository;

  final CurrentBooruConfigRepository _currentUserBooruRepository;
  final DanbooruApi _api;
  @override
  final SettingsRepository settingsRepository;

  // convert a BooruConfig and an orignal tag list to List<String>
  List<String> getTags(BooruConfig booruConfig, String tags) {
    final ratingTag = booruFilterConfigToDanbooruTag(booruConfig.ratingFilter);
    final deletedStatusTag = booruConfigDeletedBehaviorToDanbooruTag(
      booruConfig.deletedItemBehavior,
    );
    return [
      ...splitTag(tags),
      if (ratingTag != null) ratingTag,
      if (deletedStatusTag != null) deletedStatusTag,
    ];
  }

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
          .flatMap((response) => tryParseData(response));

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
