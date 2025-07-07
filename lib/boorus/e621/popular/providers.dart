// Package imports:
import 'package:booru_clients/e621.dart' as e;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/http/http.dart';
import '../../../core/posts/explores/explore.dart';
import '../../../core/posts/post/post.dart';
import '../../../foundation/caching.dart';
import '../client_provider.dart';
import '../posts/parser.dart';
import '../posts/types.dart';
import 'types.dart';

final e621PopularPostRepoProvider =
    Provider.family<E621PopularRepository, BooruConfigAuth>((ref, config) {
      return E621PopularRepositoryApi(
        ref.watch(e621ClientProvider(config)),
        config,
      );
    });

class E621PopularRepositoryApi implements E621PopularRepository {
  E621PopularRepositoryApi(
    this.client,
    this.booruConfig,
  );

  final e.E621Client client;
  final BooruConfigAuth booruConfig;

  final Cache<List<E621Post>> _cache = Cache(
    maxCapacity: 5,
    staleDuration: const Duration(seconds: 10),
  );

  String _buildKey(String date, String scale) => '$date-$scale';

  @override
  PostsOrError<E621Post> getPopularPosts(DateTime date, TimeScale timeScale) =>
      TaskEither.Do(($) async {
        final dateString = dateToE621Date(date);
        final timeScaleString = timeScaleToE621TimeScale(timeScale);
        final key = _buildKey(dateString, timeScaleString);
        final cached = _cache.get(key);

        if (cached != null && cached.isNotEmpty) return cached.toResult();

        final response = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPosts(
              date: date,
              scale: switch (timeScale) {
                TimeScale.day => e.TimeScale.day,
                TimeScale.week => e.TimeScale.week,
                TimeScale.month => e.TimeScale.month,
              },
            ),
          ),
        );

        final data = response.map(postDtoToPostNoMetadata).toList();

        final filteredNoImage = filterPostWithNoImage(data);

        _cache.set(key, filteredNoImage);

        return filteredNoImage.toResult();
      });
}

String dateToE621Date(DateTime date) =>
    '${date.year}-${date.month}-${date.day}';

String timeScaleToE621TimeScale(TimeScale timeScale) => timeScale.name;

List<E621Post> filterPostWithNoImage(List<E621Post> posts) =>
    posts.where((post) => !post.hasNoImage).toList();
