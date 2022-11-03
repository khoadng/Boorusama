// Project imports:
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_search.dart';

abstract class SavedSearchRepository {
  Future<List<SavedSearch>> getSavedSearches({
    required int page,
  });

  Future<SavedSearch?> createSavedSearch({
    required String query,
    String? label,
  });

  Future<SavedSearch?> updateSavedSearch(
    int id, {
    String? query,
    String? label,
  });

  Future<bool> deleteSavedSearch(int id);
}
