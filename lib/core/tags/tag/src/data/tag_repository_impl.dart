// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../types/tag.dart';
import '../types/tag_repository.dart';

class EmptyTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async => [];
}

class TagRepositoryBuilder implements TagRepository {
  TagRepositoryBuilder({
    required this.getTags,
  });

  final Future<List<Tag>> Function(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  })
  getTags;

  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) => getTags(
    tags,
    page,
    cancelToken: cancelToken,
  );
}
