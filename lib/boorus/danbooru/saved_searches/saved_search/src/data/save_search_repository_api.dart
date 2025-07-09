// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/saved_search.dart';
import '../types/saved_search_repository.dart';
import 'converter.dart';

class SavedSearchRepositoryApi implements SavedSearchRepository {
  const SavedSearchRepositoryApi(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  }) => client
      .getSavedSearches(
        page: page,
        //TODO: shouldn't hardcode it
        limit: 1000,
      )
      .then((value) => value.map(savedSearchDtoToSaveSearch).toList());

  @override
  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  }) => client
      .postSavedSearch(
        query: query,
        label: label,
      )
      .then(savedSearchDtoToSaveSearch);

  @override
  Future<bool> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  }) => client
      .patchSavedSearch(
        id: id,
        query: query,
        label: label,
      )
      .then((value) => true)
      .catchError((obj) => false);

  @override
  Future<bool> deleteSavedSearch(int id) => client
      .deleteSavedSearch(id: id)
      .then((value) => true)
      .catchError((obj) => false);
}
