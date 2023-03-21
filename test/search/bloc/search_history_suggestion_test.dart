// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/domain/searches/searches.dart';

class MockSearchHistoryRepository extends Mock
    implements SearchHistoryRepository {}

SearchHistory history(String term) => historyWithCount(term, 0);

SearchHistory historyWithCount(String term, int count) => SearchHistory(
      query: term,
      createdAt: DateTime(1),
      searchCount: count,
    );

HistorySuggestion suggestion(SearchHistory history, String query) =>
    HistorySuggestion(
      term: query,
      tag: history.query,
      searchHistory: history,
    );

void main() {
  final searchHistoryRepo = MockSearchHistoryRepository();

  blocTest<SearchHistorySuggestionsBloc, SearchHistorySuggestionsState>(
    'when history is fetched, show search correct filtered suggestions',
    setUp: () {
      when(() => searchHistoryRepo.getHistories()).thenAnswer((_) async => [
            history('foo'),
            history('bar'),
            history('foobar'),
          ]);
    },
    build: () => SearchHistorySuggestionsBloc(
      searchHistoryRepository: searchHistoryRepo,
    ),
    act: (bloc) => bloc.add(const SearchHistorySuggestionsFetched(text: 'foo')),
    expect: () => [
      SearchHistorySuggestionsState(histories: [
        suggestion(history('foo'), 'foo'),
        suggestion(history('foobar'), 'foo'),
      ]),
    ],
  );

  blocTest<SearchHistorySuggestionsBloc, SearchHistorySuggestionsState>(
    'when history is fetched, result should be ordered by most searched count',
    setUp: () {
      when(() => searchHistoryRepo.getHistories()).thenAnswer((_) async => [
            historyWithCount('foo', 1),
            historyWithCount('bar', 1),
            historyWithCount('foobar', 10),
          ]);
    },
    build: () => SearchHistorySuggestionsBloc(
      searchHistoryRepository: searchHistoryRepo,
    ),
    act: (bloc) => bloc.add(const SearchHistorySuggestionsFetched(text: 'foo')),
    expect: () => [
      SearchHistorySuggestionsState(histories: [
        suggestion(historyWithCount('foobar', 10), 'foo'),
        suggestion(historyWithCount('foo', 1), 'foo'),
      ]),
    ],
  );
}
