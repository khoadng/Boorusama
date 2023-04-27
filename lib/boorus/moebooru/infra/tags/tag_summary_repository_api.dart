// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/moebooru.dart';
import 'package:boorusama/boorus/moebooru/domain/tags.dart';
import 'package:boorusama/boorus/moebooru/infra/tags.dart';

class MoebooruTagSummaryRepository implements TagSummaryRepository {
  MoebooruTagSummaryRepository(this._api);

  final MoebooruApi _api;

  @override
  Future<List<TagSummary>> getTagSummaries() async {
    try {
      var response = await _api.getTagSummary();
      if ([200, 304].contains(response.response.statusCode)) {
        var tagSummaryDto = TagSummaryDto.fromJson(response.data);

        return convertTagSummaryDtoToTagSummaryList(tagSummaryDto);
      } else {
        throw Exception(
            'Failed to get tag summaries: ${response.response.statusCode}');
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        rethrow;
      } else {
        throw Exception('Failed to get tag summaries: ${e.message}');
      }
    }
  }
}

List<TagSummary> convertTagSummaryDtoToTagSummaryList(
    TagSummaryDto tagSummaryDto) {
  if (tagSummaryDto.data == null) {
    throw Exception('Tag summary data is null');
  }

  List<String> tagDataList = tagSummaryDto.data!.split(' ');
  List<TagSummary> tagSummaryList = [];

  for (String tagData in tagDataList) {
    if (tagData.isEmpty) {
      continue;
    }

    List<String> tagFields = tagData.split('`');

    if (tagFields.length < 2) {
      throw Exception('Invalid tag summary data format: $tagData');
    }

    int? category = int.tryParse(tagFields[0]);
    String? name = tagFields[1];
    Set<String> otherNames = {};

    for (String otherName in tagFields.skip(2)) {
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
