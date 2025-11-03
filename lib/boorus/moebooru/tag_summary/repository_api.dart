// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../../../core/http/client/types.dart';
import 'parser.dart';
import 'repository_file.dart';
import 'types.dart';

class MoebooruTagSummaryRepository
    with RequestDeduplicator<TagSummaryDto>
    implements TagSummaryRepository {
  MoebooruTagSummaryRepository(
    this.client,
    this.store,
  );

  final MoebooruClient client;
  final TagSummaryRepositoryFile store;

  @override
  Future<List<TagSummary>> getTagSummaries() async {
    try {
      final cached = await store.getTagSummaries();

      if (cached != null) {
        return convertTagSummaryDtoToTagSummaryList(cached);
      }

      final tagSummaryDto = await deduplicate(
        'key',
        () => client.getTagSummary(),
      );

      await store.saveTagSummaries(tagSummaryDto);

      final data = convertTagSummaryDtoToTagSummaryList(tagSummaryDto);

      return data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      } else {
        throw Exception('Failed to get tag summaries: ${e.message}');
      }
    }
  }
}
