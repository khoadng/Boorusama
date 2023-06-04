// Project imports:
import 'package:boorusama/boorus/core/feat/autocompletes/autocomplete.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}
