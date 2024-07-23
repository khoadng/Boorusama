// Project imports:
import 'package:boorusama/core/autocompletes/autocomplete.dart';

AutocompleteData autocompleteData([String? value]) => value != null
    ? AutocompleteData(label: value, value: value)
    : AutocompleteData.empty;
