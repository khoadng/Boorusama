// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';

AutocompleteData autocompleteData([String? value, String? antecedent]) =>
    value != null
        ? AutocompleteData(
            label: value,
            value: value,
            antecedent: antecedent,
          )
        : AutocompleteData.empty;
