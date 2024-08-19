// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'tag_summary.dart';
import 'tag_summary_repository.dart';

class MoebooruTagRepository extends TagRepository {
  MoebooruTagRepository({
    required this.repo,
  });

  final TagSummaryRepository repo;

  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async {
    final value = tags.map((e) => e.trim()).toList();

    final data = await repo.getTagSummaries();
    final map = {for (final item in data) item.name: item};

    return value
        .map((e) => map[e])
        .whereNotNull()
        .map(tagSummaryToTag)
        .toList();
  }
}

Tag tagSummaryToTag(TagSummary tagSummary) => Tag.noCount(
      name: tagSummary.name,
      category: TagCategory.fromLegacyId(tagSummary.category),
    );
