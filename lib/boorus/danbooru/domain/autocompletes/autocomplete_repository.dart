// Project imports:
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}
