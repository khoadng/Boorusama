// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/core/application/search.dart';

class GelbooruSearchBloc extends SearchBloc {
  GelbooruSearchBloc({
    required super.initial,
    required this.postBloc,
    required super.tagSearchBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  });

  final GelbooruPostBloc postBloc;

  @override
  void onSearch(String query) {
    postBloc.add(GelbooruPostBlocRefreshed(
      tag: query,
    ));
  }
}
