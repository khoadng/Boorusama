// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_cubit.dart';
import 'package:boorusama/core/application/search.dart';

class GelbooruSearchBloc extends SearchBloc {
  GelbooruSearchBloc({
    required super.initial,
    required this.postCubit,
    required super.tagSearchBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  });

  final GelbooruPostCubit postCubit;

  @override
  void onSearch(String query) {
    postCubit.setTags(query);
    postCubit.refresh();
  }
}
