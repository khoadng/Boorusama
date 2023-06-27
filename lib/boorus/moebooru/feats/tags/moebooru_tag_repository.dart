// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'tag_summary.dart';
import 'tag_summary_repository.dart';

class MoebooruTagRepository extends TagRepository {
  MoebooruTagRepository({
    required this.repo,
  });

  final TagSummaryRepository repo;

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    final tags = stringComma.split(',').map((e) => e.trim()).toList();

    final data = await repo.getTagSummaries();
    final map = {for (var item in data) item.name: item};

    return tags.map((e) => map[e]).whereNotNull().map(tagSummaryToTag).toList();
  }
}

Tag tagSummaryToTag(TagSummary tagSummary) => Tag(
      name: tagSummary.name,
      category: intToTagCategory(tagSummary.category),
      postCount: 0,
    );
