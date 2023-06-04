// Project imports:
import 'package:boorusama/core/autocompletes/autocomplete.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}
