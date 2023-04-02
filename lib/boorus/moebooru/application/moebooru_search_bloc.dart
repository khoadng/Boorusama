// Project imports:
import 'package:boorusama/boorus/moebooru/application/moebooru_post_bloc.dart';
import 'package:boorusama/core/application/search.dart';

class MoebooruSearchBloc extends SearchBloc {
  MoebooruSearchBloc({
    required super.initial,
    required this.postBloc,
    required super.tagSearchBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  });

  final MoebooruPostBloc postBloc;

  @override
  void onSearch(String query) {
    postBloc.add(MoebooruPostBlocRefreshed(
      tag: query,
    ));
  }
}
