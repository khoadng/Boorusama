// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class ArtistCacher implements ArtistRepository {
  const ArtistCacher({
    required this.repo,
    required this.cache,
  });

  final ArtistRepository repo;
  final Cacher<String, Artist> cache;

  @override
  Future<Artist> getArtist(
    String name, {
    CancelToken? cancelToken,
  }) async {
    final item = cache.get(name);

    if (item != null) return item;

    final fresh = await repo.getArtist(
      name,
      cancelToken: cancelToken,
    );
    await cache.put(name, fresh);

    return fresh;
  }
}
