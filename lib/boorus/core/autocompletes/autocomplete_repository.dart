// Project imports:
import 'package:boorusama/boorus/core/autocompletes/autocomplete.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}
