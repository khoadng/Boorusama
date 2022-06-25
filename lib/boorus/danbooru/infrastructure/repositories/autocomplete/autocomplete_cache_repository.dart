// Project imports:
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/autocomplete/autocomplete_repository.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

class AutocompleteCacheRepository implements AutocompleteRepository {
  const AutocompleteCacheRepository({
    required Cacher cacher,
    required AutocompleteRepository repo,
  })  : _cacher = cacher,
        _autocompleteRepository = repo;

  final Cacher _cacher;
  final AutocompleteRepository _autocompleteRepository;

  @override
  Future<List<AutocompleteData>> getAutocomplete(String query) async {
    if (_cacher.exist(query)) return _cacher.get(query);

    final fresh = await _autocompleteRepository.getAutocomplete(query);
    _cacher.put(query, fresh);

    return fresh;
  }
}
