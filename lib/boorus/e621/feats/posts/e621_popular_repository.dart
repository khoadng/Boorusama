// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';

abstract interface class E621PopularRepository {
  E621PostsOrError getPopularPosts(DateTime date, TimeScale timeScale);
}

class E621PopularRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements E621PopularRepository {
  E621PopularRepositoryApi(
    this.api,
    this.booruConfig,
    this.settingsRepository,
    this.blacklistedTagRepository,
  );

  final E621Api api;
  final BooruConfig booruConfig;

  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  final Cache<List<E621Post>> _cache = Cache(
    maxCapacity: 5,
    staleDuration: const Duration(seconds: 10),
  );

  String _buildKey(String date, String scale) => '$date-$scale';

  @override
  E621PostsOrError getPopularPosts(DateTime date, TimeScale timeScale) =>
      TaskEither.Do(($) async {
        final dateString = dateToE621Date(date);
        final timeScaleString = timeScaleToE621TimeScale(timeScale);
        final key = _buildKey(dateString, timeScaleString);
        final cached = _cache.get(key);

        if (cached != null && cached.isNotEmpty) {
          return cached;
        }

        final response = await $(tryParseResponse(
          fetcher: () => api.getPopularPosts(
            booruConfig.login,
            booruConfig.apiKey,
            dateString,
            timeScaleString,
          ),
        ));

        final data = await $(tryParseData(response));

        final filtered = await $(tryFilterBlacklistedTags(data));
        final filteredNoImage = filterPostWithNoImage(filtered);

        _cache.set(key, filteredNoImage);

        return filteredNoImage;
      });
}

String dateToE621Date(DateTime date) =>
    '${date.year}-${date.month}-${date.day}';

String timeScaleToE621TimeScale(TimeScale timeScale) => timeScale.name;

List<E621Post> filterPostWithNoImage(List<E621Post> posts) =>
    posts.where((post) => !post.hasNoImage).toList();
