// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/caching/caching.dart';

class TagCacher implements TagRepository {
  TagCacher({
    required this.cache,
    required this.repo,
  });

  final TagRepository repo;
  final Cacher<String, Tag> cache;

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    final tags = stringComma.split(',');
    final cachedTags = tags
        .where((tag) => cache.exist(tag))
        .map((e) => cache.get(e)!)
        .toList();

    final freshTagKeys = tags.where((tag) => !cache.exist(tag)).toList();
    var freshTags = <Tag>[];

    if (freshTagKeys.isNotEmpty) {
      freshTags = await repo.getTagsByNameComma(freshTagKeys.join(','), page);
    }

    for (final tag in freshTags) {
      await cache.put(tag.rawName, tag);
    }

    return [...cachedTags, ...freshTags];
  }
}
