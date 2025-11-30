// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/database/indexed_db_store.dart';
import '../../../selected_tags/types.dart';
import '../types/search_history.dart';
import '../types/search_history_repository.dart';

const kSearchHistoryDbName = 'search_history_db';
const _kQueryTypeIndex = 'query_type';
const _kUpdatedAtIndex = 'updated_at';

final searchHistoryRepoProvider = FutureProvider<SearchHistoryRepository>(
  (ref) async {
    final repo = SearchHistoryRepositoryIndexedDb();
    await repo.initialize();
    return repo;
  },
);

Future<String> getSearchHistoryDbPath() async {
  return '';
}

class SearchHistoryRepositoryIndexedDb implements SearchHistoryRepository {
  late final IndexedDbStore _store;

  Future<void> initialize() async {
    _store = IndexedDbStore(
      dbName: kSearchHistoryDbName,
      storeName: kSearchHistoryTable,
    );

    await _store.initialize(
      indexes: [
        const IndexConfig(
          name: _kQueryTypeIndex,
          keyPath: ['query', 'type'],
          unique: true,
        ),
        const IndexConfig(
          name: _kUpdatedAtIndex,
          keyPath: ['updated_at'],
        ),
      ],
    );
  }

  @override
  Future<List<SearchHistory>> getHistories() async {
    final items = await _store.getAll(
      indexName: _kUpdatedAtIndex,
      direction: 'prev',
    );
    return items.map(SearchHistory.fromMap).toList();
  }

  @override
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
    required String booruTypeName,
    required String siteUrl,
  }) async {
    if (query.isEmpty) return getHistories();

    final existing = await _store.getByIndex(
      _kQueryTypeIndex,
      [query, queryType.name],
    );

    if (existing != null) {
      final history = SearchHistory.fromMap(existing);
      final updated = history
          .copyWith(
            searchCount: history.searchCount + 1,
            updatedAt: DateTime.now().toUtc(),
          )
          .toMap();

      final key = await _store.findKey(
        _kQueryTypeIndex,
        [query, queryType.name],
      );
      if (key != null) {
        await _store.put(updated, key);
      }
    } else {
      final newHistory = SearchHistory.now(
        query,
        queryType,
        booruTypeName: booruTypeName,
        siteUrl: siteUrl,
      ).toMap();
      await _store.add(newHistory);
    }

    return getHistories();
  }

  @override
  Future<List<SearchHistory>> removeHistory(SearchHistory history) async {
    final key = await _store.findKey(
      _kQueryTypeIndex,
      [history.query, history.queryType?.name ?? ''],
    );

    if (key != null) {
      await _store.delete(key);
    }

    return getHistories();
  }

  @override
  Future<bool> clearAll() async {
    await _store.clear();
    return true;
  }
}
