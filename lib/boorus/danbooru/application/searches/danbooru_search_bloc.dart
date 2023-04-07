// Package imports:
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/posts/post_cubit.dart';
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
    required this.postCubit,
    required super.tagSearchBloc,
    required this.relatedTagBloc,
    required super.searchHistoryBloc,
    required super.searchHistorySuggestionsBloc,
    required this.postCountRepository,
    required super.metatags,
    required super.booruType,
    super.initialQuery,
  }) {
    on<SearchRelatedTagSelected>((event, emit) {
      add(SearchRawTagSelected(tag: event.tag.tag));
    });
  }

  final DanbooruPostCubit postCubit;
  final RelatedTagBloc relatedTagBloc;
  final PostCountRepository postCountRepository;

  @override
  void onBackToOptions() {
    postCubit.reset();
  }

  @override
  void onSearch(String query) {
    relatedTagBloc.add(RelatedTagRequested(query: query));
    postCubit.setTags(query);
    postCubit.refresh();
  }

  @override
  Future<int?> fetchPostCount(List<String> tags) =>
      postCountRepository.count(tags);
}
