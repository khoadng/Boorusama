// Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

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
    final settings = _ref.watch(settingsNotifier.state).settings;

    return settings.searchHistories;
  }

  @override
  Future<bool> addHistory(String query) async {
    try {
      final settings = _ref.watch(settingsNotifier.state).settings;

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

      final success = _ref.read(settingsNotifier).save(settings);

      return true;
    } on Exception {
      return Future.value(false);
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      final settings = _ref.watch(settingsNotifier.state).settings;

      settings.searchHistories.clear();

      final success = _ref.read(settingsNotifier).save(settings);

      return true;
    } on Exception {
      return Future.value(false);
    }
  }
}
