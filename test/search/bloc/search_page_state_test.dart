// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';

void main() {
  group('search page state', () {
    SearchState searchStateEmpty() =>
        const SearchState(displayState: DisplayState.suggestion);

    SearchBloc bloc([SearchState? initial]) =>
        SearchBloc(initial: initial ?? searchStateEmpty());

    blocTest<SearchBloc, SearchState>(
      'when suggestions are received, switch to suggestion state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchSuggestionReceived()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.suggestion),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when a search requested, switch to result state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchRequested()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.result),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when search options is requested, switch to options state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchGoBackToSearchOptionsRequested()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.options),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when selected tag is cleared, switch to options state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchSelectedTagCleared()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.options),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when query is empty, switch to options state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchQueryEmpty()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.options),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when query is empty but already in result state, no state changed',
      build: () =>
          bloc(searchStateEmpty().copyWith(displayState: DisplayState.result)),
      act: (bloc) => bloc.add(const SearchQueryEmpty()),
      expect: () => [],
    );

    blocTest<SearchBloc, SearchState>(
      'when search has error, switch to error state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchError()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.error),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when search has no data, switch to no result state',
      build: () => bloc(),
      act: (bloc) => bloc.add(const SearchNoData()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.noResult),
      ],
    );
  });
}
