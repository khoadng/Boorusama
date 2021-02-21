// Package imports:
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';

final searchHistoryProvider = Provider<ISearchHistoryRepository>((ref) {
  return SearchHistoryRepository(ref: ref);
});

class SearchHistoryRepository implements ISearchHistoryRepository {
  SearchHistoryRepository({
    @required ProviderReference ref,
  }) : _ref = ref;

  ProviderReference _ref;

  @override
  Future<List<SearchHistory>> getHistories() async {
    final settingsRepository = await _ref.watch(settingsProvider.future);
    final settings = await settingsRepository.load();

    return settings.searchHistories;
  }

  @override
  Future<bool> addHistory(String query) async {
    try {
      final settingsRepository = await _ref.watch(settingsProvider.future);
      final settings = await settingsRepository.load();

      if (query.isEmpty) {
        return true;
      }

      if (!settings.searchHistories.any((item) => item.query == query)) {
        settings.searchHistories.add(
          SearchHistory(query: query, createdAt: DateTime.now()),
        );
      } else {
        settings.searchHistories.removeWhere((item) => item.query == query);
        settings.searchHistories.add(
          SearchHistory(query: query, createdAt: DateTime.now()),
        );
      }

      final success = await settingsRepository.save(settings);

      return success;
    } on Exception {
      return Future.value(false);
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      final settingsRepository = await _ref.watch(settingsProvider.future);
      final settings = await settingsRepository.load();

      settings.searchHistories.clear();

      final success = await settingsRepository.save(settings);

      return success;
    } on Exception {
      return Future.value(false);
    }
  }
}
