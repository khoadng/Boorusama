// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/moebooru/moebooru_api.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/foundation/http/request_deduplicator_mixin.dart';
import 'converter.dart';
import 'tag_summary_repository_file.dart';

class MoebooruTagSummaryRepository
    with RequestDeduplicator<HttpResponse<dynamic>>
    implements TagSummaryRepository {
  MoebooruTagSummaryRepository(
    this.api,
    this.store,
  );

  final MoebooruApi api;
  final TagSummaryRepositoryFile store;

  @override
  Future<List<TagSummary>> getTagSummaries() async {
    try {
      final cached = await store.getTagSummaries();

      if (cached != null) {
        return convertTagSummaryDtoToTagSummaryList(cached);
      }

      var response = await deduplicate('key', () => api.getTagSummary());

      if ([200, 304].contains(response.response.statusCode)) {
        var tagSummaryDto = TagSummaryDto.fromJson(response.data);

        await store.saveTagSummaries(tagSummaryDto);

        final data = convertTagSummaryDtoToTagSummaryList(tagSummaryDto);

        return data;
      } else {
        throw Exception(
            'Failed to get tag summaries: ${response.response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      } else {
        throw Exception('Failed to get tag summaries: ${e.message}');
      }
    }
  }
}
