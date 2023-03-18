// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/core/application/common.dart';

class MockSavedSearchRepository extends Mock implements SavedSearchRepository {}

void main() {
  final savedSearchRepo = MockSavedSearchRepository();

  group('[fetch saved searches]', () {
    blocTest<SavedSearchBloc, SavedSearchState>(
      'fetch 2 items',
      setUp: () {
        when(() => savedSearchRepo.getSavedSearches(page: any(named: 'page')))
            .thenAnswer((invocation) async => [
                  SavedSearch.empty().copyWith(id: 1, query: 'foo'),
                  SavedSearch.empty().copyWith(id: 2, query: 'bar'),
                ]);
      },
      tearDown: () {
        reset(savedSearchRepo);
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(const SavedSearchFetched()),
      expect: () => [
        SavedSearchState.initial().copyWith(refreshing: true),
        SavedSearchState.initial().copyWith(
          refreshing: false,
          status: LoadStatus.success,
          data: [
            SavedSearch.empty().copyWith(id: 1, query: 'foo'),
            SavedSearch.empty().copyWith(id: 2, query: 'bar'),
          ],
        ),
      ],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'exception',
      setUp: () {
        when(() => savedSearchRepo.getSavedSearches(page: any(named: 'page')))
            .thenThrow(Exception());
      },
      tearDown: () {
        reset(savedSearchRepo);
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(const SavedSearchFetched()),
      expect: () => [
        SavedSearchState.initial().copyWith(
          refreshing: true,
        ),
        SavedSearchState.initial().copyWith(
          refreshing: false,
          status: LoadStatus.failure,
        ),
      ],
    );
  });

  group('[create a saved search]', () {
    Completer? completer;

    blocTest<SavedSearchBloc, SavedSearchState>(
      'success',
      setUp: () {
        completer = Completer();
        when(() =>
                savedSearchRepo.createSavedSearch(query: any(named: 'query')))
            .thenAnswer(
          (_) async => SavedSearch.empty().copyWith(id: 1, query: 'foo'),
        );
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchCreated(
        query: 'foo',
        onCreated: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [
        SavedSearchState.initial().copyWith(
          data: [
            SavedSearch.empty().copyWith(id: 1, query: 'foo'),
          ],
        ),
      ],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'fail to create',
      setUp: () {
        completer = Completer();
        when(() =>
                savedSearchRepo.createSavedSearch(query: any(named: 'query')))
            .thenAnswer((_) async => null);
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchCreated(
        query: 'foo',
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'exception throw',
      setUp: () {
        completer = Completer();
        when(() =>
                savedSearchRepo.createSavedSearch(query: any(named: 'query')))
            .thenThrow(Exception());
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchCreated(
        query: 'foo',
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );
  });

  group('[delete a saved search]', () {
    Completer? completer;

    blocTest<SavedSearchBloc, SavedSearchState>(
      'success',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.deleteSavedSearch(any()))
            .thenAnswer((_) async => true);
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      seed: () => SavedSearchState.initial().copyWith(
        data: [
          SavedSearch.empty().copyWith(id: 1, canDelete: true),
        ],
      ),
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchDeleted(
        savedSearch: SavedSearch.empty().copyWith(id: 1, canDelete: true),
        onDeleted: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [
        SavedSearchState.initial().copyWith(
          data: [],
        ),
      ],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'ignore search that is undeletable',
      setUp: () {
        when(() => savedSearchRepo.deleteSavedSearch(any()))
            .thenAnswer((_) async => false);
      },
      tearDown: () {
        reset(savedSearchRepo);
      },
      seed: () => SavedSearchState.initial().copyWith(
        data: [
          SavedSearch.empty().copyWith(id: 1, canDelete: false),
        ],
      ),
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchDeleted(
        savedSearch: SavedSearch.empty().copyWith(id: 1, canDelete: false),
      )),
      expect: () => [],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'fail to delete',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.deleteSavedSearch(any()))
            .thenAnswer((_) async => false);
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      seed: () => SavedSearchState.initial().copyWith(
        data: [
          SavedSearch.empty().copyWith(id: 1, canDelete: true),
        ],
      ),
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchDeleted(
        savedSearch: SavedSearch.empty().copyWith(id: 1, canDelete: true),
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'exception throw',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.deleteSavedSearch(any()))
            .thenThrow(Exception());
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchDeleted(
        savedSearch: SavedSearch.empty().copyWith(id: 1, canDelete: true),
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );
  });

  group('[update a saved search]', () {
    Completer? completer;

    blocTest<SavedSearchBloc, SavedSearchState>(
      'success',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.updateSavedSearch(
              any(),
              query: any(named: 'query'),
              label: any(named: 'label'),
            )).thenAnswer(
          (_) async => true,
        );
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      seed: () => SavedSearchState.initial().copyWith(
        data: [
          SavedSearch.empty().copyWith(id: 1, query: 'foo'),
        ],
      ),
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchUpdated(
        id: 1,
        query: 'newfoo',
        onUpdated: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [
        SavedSearchState.initial().copyWith(
          data: [
            SavedSearch.empty().copyWith(
              id: 1,
              query: 'newfoo',
            ),
          ],
        ),
      ],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'fail to update',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.updateSavedSearch(
              any(),
              query: any(named: 'query'),
              label: any(named: 'label'),
            )).thenAnswer((_) async => false);
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      seed: () => SavedSearchState.initial().copyWith(
        data: [
          SavedSearch.empty().copyWith(id: 1),
        ],
      ),
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchUpdated(
        id: 1,
        query: 'newfoo',
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );

    blocTest<SavedSearchBloc, SavedSearchState>(
      'exception throw',
      setUp: () {
        completer = Completer();
        when(() => savedSearchRepo.updateSavedSearch(
              any(),
              query: any(named: 'query'),
              label: any(named: 'label'),
            )).thenThrow(Exception());
      },
      tearDown: () {
        reset(savedSearchRepo);
        completer = null;
      },
      build: () => SavedSearchBloc(
        savedSearchRepository: savedSearchRepo,
      ),
      act: (bloc) => bloc.add(SavedSearchUpdated(
        id: 1,
        query: 'newfoo',
        onFailure: completer!.complete,
      )),
      verify: (bloc) {
        expect(completer!.isCompleted, isTrue);
      },
      expect: () => [],
    );
  });
}
