// Project imports:
import 'package:boorusama/boorus/moebooru/application/posts/moebooru_post_cubit.dart';
import 'package:boorusama/core/application/search.dart';

class MoebooruSearchBloc extends SearchBloc {
  MoebooruSearchBloc({
    required super.initial,
    required this.postCubit,
    required super.tagSearchBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  });

  final MoebooruPostCubit postCubit;

  @override
  void onSearch(String query) {
    postCubit.setTags(query);
    postCubit.refresh();
  }
}
