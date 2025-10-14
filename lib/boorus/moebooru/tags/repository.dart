// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../core/tags/tag/types.dart';
import '../tag_summary/types.dart';
import 'parser.dart';

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

    return value.map((e) => map[e]).nonNulls.map(tagSummaryToTag).toList();
  }
}
