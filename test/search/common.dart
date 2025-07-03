// Project imports:
import 'package:boorusama/core/tags/autocompletes/types.dart';

AutocompleteData autocompleteData([String? value, String? antecedent]) =>
    value != null
        ? AutocompleteData(
            label: value,
            value: value,
            antecedent: antecedent,
          )
        : AutocompleteData.empty;
