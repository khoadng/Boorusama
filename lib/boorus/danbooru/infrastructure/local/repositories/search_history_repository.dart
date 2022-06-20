// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';

class SearchHistoryRepository implements ISearchHistoryRepository {
  SearchHistoryRepository({
    required this.settingRepository,
  });

  final ISettingRepository settingRepository;

  @override
  Future<List<SearchHistory>> getHistories() async {
    final settings = await settingRepository.load();

    return settings.searchHistories.toList();
  }

  @override
  Future<List<SearchHistory>> addHistory(String query) async {
    try {
      final settings = await settingRepository.load();

      if (query.isEmpty) {
        return settings.searchHistories.toList();
      }
      final shs = settings.searchHistories.toList();
      final sh = SearchHistory(query: query, createdAt: DateTime.now());

      if (!settings.searchHistories.any((item) => item.query == query)) {
        shs.add(sh);
      } else {
        shs
          ..removeWhere((item) => item.query == query)
          ..add(sh);
      }

      await settingRepository.save(settings.copyWith(searchHistories: shs));

      return shs;
    } on Exception {
      return Future.value([]);
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      final settings = await settingRepository.load();

      final success =
          await settingRepository.save(settings.copyWith(searchHistories: []));

      return success;
    } on Exception {
      return Future.value(false);
    }
  }
}
