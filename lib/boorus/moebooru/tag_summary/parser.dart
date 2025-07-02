// Package imports:
import 'package:booru_clients/moebooru.dart';

// Project imports:
import 'types.dart';

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

    tagSummaryList.add(
      TagSummary(
        category: category ?? 0,
        name: name,
        otherNames: otherNames.isEmpty ? [] : List<String>.from(otherNames),
      ),
    );
  }

  return tagSummaryList;
}
