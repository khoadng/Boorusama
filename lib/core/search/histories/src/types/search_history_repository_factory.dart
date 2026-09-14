import 'search_history_repository.dart';

abstract interface class SearchHistoryRepositoryFactory {
  Future<SearchHistoryRepository> create();

  Future<void> dispose(SearchHistoryRepository repository);
}
