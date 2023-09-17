// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/clients/moebooru/types/types.dart';
import 'package:boorusama/foundation/http/request_deduplicator_mixin.dart';
import 'tag_summary.dart';
import 'tag_summary_repository.dart';
import 'tag_summary_repository_file.dart';

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

      var tagSummaryDto =
          await deduplicate('key', () => client.getTagSummary());

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
