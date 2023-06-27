// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/moebooru/moebooru_api.dart';
import 'package:boorusama/foundation/http/request_deduplicator_mixin.dart';
import 'tag_summary.dart';
import 'tag_summary_dto.dart';
import 'tag_summary_repository.dart';
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

List<TagSummary> convertTagSummaryDtoToTagSummaryList(
  TagSummaryDto tagSummaryDto,
) {
  if (tagSummaryDto.data == null) {
    throw Exception('Tag summary data is null');
  }

  final tagDataList = tagSummaryDto.data!.split(' ');
  final tagSummaryList = <TagSummary>[];

  for (final tagData in tagDataList) {
    if (tagData.isEmpty) {
      continue;
    }

    final tagFields = tagData.split('`');

    if (tagFields.length < 2) {
      throw Exception('Invalid tag summary data format: $tagData');
    }

    final category = int.tryParse(tagFields[0]);
    final name = tagFields[1];
    final otherNames = <String>{};

    for (final otherName in tagFields.skip(2)) {
      if (otherName.isNotEmpty) {
        otherNames.add(otherName);
      }
    }

    tagSummaryList.add(TagSummary(
      category: category ?? 0,
      name: name,
      otherNames: otherNames.isEmpty ? [] : List<String>.from(otherNames),
    ));
  }

  return tagSummaryList;
}
