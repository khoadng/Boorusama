// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

class ArtistCommentaryCacher implements IArtistCommentaryRepository {
  ArtistCommentaryCacher({
    required this.cache,
    required this.repo,
  });

  final Cacher cache;
  final IArtistCommentaryRepository repo;

  @override
  Future<ArtistCommentaryDto> getCommentary(
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
    cache.put(key, fresh);

    return fresh;
  }
}
