// Package imports:
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/common.dart';
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
    required this.postBloc,
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

  final PostBloc postBloc;
  final RelatedTagBloc relatedTagBloc;
  final PostCountRepository postCountRepository;

  @override
  void onBackToOptions() {
    postBloc.add(const PostReset());
  }

  @override
  void onSearch(String query) {
    relatedTagBloc.add(RelatedTagRequested(query: query));

    postBloc.add(PostRefreshed(
      tag: query,
      fetcher: SearchedPostFetcher.fromTags(query),
    ));
  }

  @override
  Future<int?> fetchPostCount(List<String> tags) =>
      postCountRepository.count(tags);

  @override
  void onInit() {
    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
      stream,
      postBloc.stream,
      Tuple2.new,
    )
        .where((event) =>
            event.item2.status == LoadStatus.success &&
            event.item2.posts.isEmpty &&
            event.item1.displayState == DisplayState.result)
        .listen((state) => add(const SearchNoData()))
        .addTo(compositeSubscription);

    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
      stream,
      postBloc.stream,
      Tuple2.new,
    )
        .where((event) =>
            event.item2.status == LoadStatus.failure &&
            event.item1.displayState == DisplayState.result)
        .listen((state) => add(SearchError(state.item2.exceptionMessage!)))
        .addTo(compositeSubscription);
  }
}
