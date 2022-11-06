// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';

class MockSavedSearchBloc extends MockBloc<SavedSearchEvent, SavedSearchState>
    implements SavedSearchBloc {}

final _fooSavedSearch = SavedSearch.empty().copyWith(
  id: 1,
  labels: ['foo'],
  query: 'foo',
);

void main() {
  final savedSearchBloc = MockSavedSearchBloc();

  blocTest<SavedSearchFeedBloc, SavedSearchFeedState>(
    'should append the ALL tag at first position and select it when refreshed',
    setUp: () {
      whenListen(
        savedSearchBloc,
        Stream.fromIterable([
          SavedSearchState.initial(),
          SavedSearchState.initial().copyWith(
            data: [
              _fooSavedSearch,
            ],
            status: LoadStatus.success,
          ),
        ]),
      );
    },
    tearDown: () {
      reset(savedSearchBloc);
    },
    build: () => SavedSearchFeedBloc(
      savedSearchBloc: savedSearchBloc,
    ),
    act: (bloc) => bloc.add(const SavedSearchFeedRefreshed()),
    expect: () => [
      SavedSearchFeedState.initial().copyWith(
        savedSearches: [
          SavedSearch.all(),
        ],
      ),
      SavedSearchFeedState.initial().copyWith(
        // Changed
        savedSearchState: SavedSearchState.initial().copyWith(
          data: [
            _fooSavedSearch,
          ],
          status: LoadStatus.success,
        ),
        savedSearches: [
          SavedSearch.all(),
          _fooSavedSearch,
        ],
      ),
      SavedSearchFeedState.initial().copyWith(
        savedSearchState: SavedSearchState.initial().copyWith(
          data: [
            _fooSavedSearch,
          ],
          status: LoadStatus.success,
        ),
        savedSearches: [
          SavedSearch.all(),
          _fooSavedSearch,
        ],
        // Changed
        selectedSearch: SavedSearch.all(),
        status: SavedSearchFeedStatus.loaded,
      ),
    ],
  );

  blocTest<SavedSearchFeedBloc, SavedSearchFeedState>(
    'searches with empty labels will be filtered',
    setUp: () {
      whenListen(
        savedSearchBloc,
        Stream.fromIterable([
          SavedSearchState.initial(),
          SavedSearchState.initial().copyWith(
            data: [
              SavedSearch.empty(),
              _fooSavedSearch,
            ],
            status: LoadStatus.success,
          ),
        ]),
      );
    },
    tearDown: () {
      reset(savedSearchBloc);
    },
    build: () => SavedSearchFeedBloc(
      savedSearchBloc: savedSearchBloc,
    ),
    act: (bloc) => bloc.add(const SavedSearchFeedRefreshed()),
    expect: () => [
      SavedSearchFeedState.initial().copyWith(
        savedSearches: [
          SavedSearch.all(),
        ],
      ),
      SavedSearchFeedState.initial().copyWith(
        // Changed
        savedSearches: [
          SavedSearch.all(),
          _fooSavedSearch,
        ],
        savedSearchState: SavedSearchState.initial().copyWith(
          data: [
            SavedSearch.empty(),
            _fooSavedSearch,
          ],
          status: LoadStatus.success,
        ),
      ),
      SavedSearchFeedState.initial().copyWith(
        savedSearchState: SavedSearchState.initial().copyWith(
          data: [
            SavedSearch.empty(),
            _fooSavedSearch,
          ],
          status: LoadStatus.success,
        ),
        // Changed
        savedSearches: [
          SavedSearch.all(),
          _fooSavedSearch,
        ],
        selectedSearch: SavedSearch.all(),
        status: SavedSearchFeedStatus.loaded,
      ),
    ],
  );
}
