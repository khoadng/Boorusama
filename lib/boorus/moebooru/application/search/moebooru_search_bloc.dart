// Project imports:
import 'package:boorusama/core/application/search.dart';

class MoebooruSearchBloc extends SearchBloc {
  MoebooruSearchBloc({
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
