// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'tag_summary.dart';
import 'tag_summary_dto.dart';

List<AutocompleteData> convertTagSummaryToAutocompleteData(
  TagSummary tagSummary,
) {
  final label = tagSummary.name;
  final value = tagSummary.name;
  final antecedents = tagSummary.otherNames.where((name) => name != label);
  final type = AutocompleteData.isTagType(tagSummary.category.toString())
      ? AutocompleteData.tag
      : null;
  final category = tagSummary.category.toString();

  List<AutocompleteData> autocompleteDataList = [
    AutocompleteData(
      label: label.replaceAll('_', ' '),
      value: value,
      antecedent: null,
      type: type,
      category: category,
    )
  ];

  if (antecedents.isNotEmpty) {
    autocompleteDataList
        .addAll(antecedents.map((antecedent) => AutocompleteData(
              label: label,
              value: label,
              antecedent: antecedent,
              type: type,
              category: category,
            )));
  }

  return autocompleteDataList;
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
