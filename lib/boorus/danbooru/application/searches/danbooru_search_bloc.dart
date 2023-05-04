// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/search.dart';

class SearchRelatedTagSelected extends SearchEvent {
  const SearchRelatedTagSelected({
    required this.tag,
  });

  final RelatedTagItem tag;

  @override
  List<Object?> get props => [tag];
}

class DanbooruSearchBloc extends SearchBloc {
  DanbooruSearchBloc({
    required super.initial,
    required super.tagSearchBloc,
    required this.relatedTagBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  }) {
    on<SearchRelatedTagSelected>((event, emit) {
      add(SearchRawTagSelected(tag: event.tag.tag));
    });
  }

  final RelatedTagBloc relatedTagBloc;

  @override
  void onBackToOptions() {
    // postCubit.reset();
  }

  @override
  void onSearch(String query) {
    //FIXME: remove a tag when in result state won't refresh the post list
    relatedTagBloc.add(RelatedTagRequested(query: query));
    // postCubit.setTags(query);
    // postCubit.refresh();
  }
}
