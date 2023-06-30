// Project imports:
import 'saved_search.dart';

abstract class SavedSearchRepository {
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  });

  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  });

  Future<bool> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  });

  Future<bool> deleteSavedSearch(int id);
}
