// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../tag_summary/types.dart';

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

  final autocompleteDataList = <AutocompleteData>[
    AutocompleteData(
      label: label.replaceAll('_', ' '),
      value: value,
      type: type,
      category: category,
    ),
  ];

  if (antecedents.isNotEmpty) {
    autocompleteDataList.addAll(
      antecedents.map(
        (antecedent) => AutocompleteData(
          label: label,
          value: label,
          antecedent: antecedent,
          type: type,
          category: category,
        ),
      ),
    );
  }

  return autocompleteDataList;
}
