// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../../../../../foundation/utils/collection_utils.dart';
import '../types/tag.dart';
import '../types/tag_repository.dart';

const kDefaultTagChunkSize = 100;
const _kServiceName = 'TagRepository';

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
    this.chunkSize = kDefaultTagChunkSize,
    this.logger,
  });

  final Future<List<Tag>> Function(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  })
  getTags;

  final int chunkSize;
  final Logger? logger;

  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async {
    if (tags.isEmpty) return [];

    final chunks = tags.toList().chunk(chunkSize);
    final results = <Tag>[];

    for (final chunk in chunks) {
      if (chunk.isEmpty) continue;
      if (cancelToken?.isCancelled ?? false) break;

      try {
        final chunkTags = await getTags(
          chunk.toSet(),
          page,
          cancelToken: cancelToken,
        );
        results.addAll(chunkTags);
      } catch (e) {
        // Log error but continue processing remaining chunks
        // This allows partial results even if some chunks fail
        logger?.warn(
          _kServiceName,
          'Failed to fetch tag chunk (${chunk.length} tags): $e',
        );
        continue;
      }
    }

    return results;
  }
}
