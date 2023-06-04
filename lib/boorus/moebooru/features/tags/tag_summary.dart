// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';

class TagSummary {
  final int category;
  final String name;
  final List<String> otherNames;

  TagSummary({
    required this.category,
    required this.name,
    required this.otherNames,
  });
}

List<AutocompleteData> convertTagSummaryToAutocompleteData(
    TagSummary tagSummary) {
  final label = tagSummary.name;
  final value = tagSummary.name;
  final antecedents = tagSummary.otherNames.where((name) => name != label);
  final type = AutocompleteData.isTagType(tagSummary.category.toString())
      ? AutocompleteData.tag
      : null;
  final category = tagSummary.category.toString();

  List<AutocompleteData> autocompleteDataList = [
    AutocompleteData(
      label: label,
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
