// Project imports:
import 'package:boorusama/core/application/search.dart';

class GelbooruSearchBloc extends SearchBloc {
  GelbooruSearchBloc({
    required super.initial,
    required super.tagSearchBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  });

  @override
  void onSearch(String query) {}
}
