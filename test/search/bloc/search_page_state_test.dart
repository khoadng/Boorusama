// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/core/application/search/search.dart';

class MockTagSearchBloc extends MockBloc<TagSearchEvent, TagSearchState>
    implements TagSearchBloc {}

void main() {
  final tagSearchBloc = MockTagSearchBloc();

  group('search page state', () {
    SearchState searchStateEmpty() =>
        const SearchState(displayState: DisplayState.suggestion);

    SearchBloc bloc(TagSearchBloc tagSearchBloc, [SearchState? initial]) =>
        SearchBloc(
          initial: initial ?? searchStateEmpty(),
          tagSearchBloc: tagSearchBloc,
        );

    blocTest<SearchBloc, SearchState>(
      'when suggestions are received, switch to suggestion state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchSuggestionReceived()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.suggestion),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when a search requested, switch to result state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchRequested()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.result),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when search options is requested, switch to options state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchGoBackToSearchOptionsRequested()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.options),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when selected tag is cleared, switch to options state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchSelectedTagCleared()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.options),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when search has error, switch to error state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchError()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.error),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'when search has no data, switch to no result state',
      build: () => bloc(tagSearchBloc),
      act: (bloc) => bloc.add(const SearchNoData()),
      expect: () => [
        searchStateEmpty().copyWith(displayState: DisplayState.noResult),
      ],
    );
  });
}
