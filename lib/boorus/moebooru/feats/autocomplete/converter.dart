// Project imports:
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/string.dart';

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
      label: label.replaceUnderscoreWithSpace(),
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
