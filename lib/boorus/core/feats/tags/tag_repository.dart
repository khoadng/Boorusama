// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';
import 'tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  });
}

class TagRepositoryBuilder with CacheMixin<Tag> implements TagRepository {
  TagRepositoryBuilder({
    required this.getTags,
    this.maxCapacity = 1000,
    this.staleDuration = const Duration(minutes: 30),
  });

  final Future<List<Tag>> Function(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) getTags;

  @override
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async {
    final cachedTags =
        tags.where((tag) => exist(tag)).map((e) => get(e)!).toList();

    final freshTagKeys = tags.where((tag) => !exist(tag)).toList();
    var freshTags = <Tag>[];

    if (freshTagKeys.isNotEmpty) {
      freshTags = await getTags(freshTagKeys, page);
    }

    for (final tag in freshTags) {
      set(tag.rawName, tag);
    }

    return [...cachedTags, ...freshTags];
  }

  @override
  final int maxCapacity;

  @override
  final Duration staleDuration;
}
