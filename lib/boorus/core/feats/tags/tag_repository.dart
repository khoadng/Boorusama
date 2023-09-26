// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  });
}

class TagRepositoryBuilder implements TagRepository {
  TagRepositoryBuilder({
    required this.getTags,
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
  }) =>
      getTagsByName(
        tags,
        page,
        cancelToken: cancelToken,
      );
}
