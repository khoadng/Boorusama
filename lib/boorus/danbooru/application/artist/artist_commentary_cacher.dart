// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class ArtistCommentaryCacher implements ArtistCommentaryRepository {
  ArtistCommentaryCacher({
    required this.cache,
    required this.repo,
  });

  final Cacher cache;
  final ArtistCommentaryRepository repo;

  @override
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final key = postId.toString();
    final items = cache.get(key);

    if (items != null) return items;

    final fresh = await repo.getCommentary(
      postId,
      cancelToken: cancelToken,
    );
    await cache.put(key, fresh);

    return fresh;
  }
}
