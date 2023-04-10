// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/wikis.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class WikiCacher implements WikiRepository {
  const WikiCacher({
    required this.cache,
    required this.repo,
  });

  final WikiRepository repo;
  final Cacher<String, Wiki?> cache;

  @override
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  }) async {
    final item = cache.get(title);

    if (item != null) return item;

    final fresh = await repo.getWikiFor(
      title,
      cancelToken: cancelToken,
    );
    await cache.put(title, fresh);

    return fresh;
  }
}
