// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocomplete.dart';

abstract class AutocompleteRepository {
  Future<List<AutocompleteData>> getAutocomplete(String query);
}

class AutocompleteRepositoryBuilder implements AutocompleteRepository {
  AutocompleteRepositoryBuilder({
    required this.autocomplete,
  });

  final Future<List<AutocompleteData>> Function(String query) autocomplete;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) =>
      autocomplete(query);
}
