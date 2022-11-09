// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';

enum SavedSearchFeedStatus {
  initial,
  noData,
  failure,
  loaded,
}

class SavedSearchFeedState extends Equatable {
  const SavedSearchFeedState({
    required this.savedSearches,
    // required this.refreshing,
    required this.status,
    required this.selectedSearch,
    required this.savedSearchState,
  });

  factory SavedSearchFeedState.initial() => SavedSearchFeedState(
        savedSearches: const [],
        // refreshing: false,
        status: SavedSearchFeedStatus.initial,
        selectedSearch: SavedSearch.empty(),
        savedSearchState: SavedSearchState.initial(),
      );

  bool get refreshing => savedSearchState.refreshing;

  final List<SavedSearch> savedSearches;
  final SavedSearchFeedStatus status;
  final SavedSearch selectedSearch;
  final SavedSearchState savedSearchState;

  SavedSearchFeedState copyWith({
    List<SavedSearch>? savedSearches,
    // bool? refreshing,
    SavedSearchFeedStatus? status,
    SavedSearch? selectedSearch,
    SavedSearchState? savedSearchState,
  }) =>
      SavedSearchFeedState(
        savedSearches: savedSearches ?? this.savedSearches,
        // refreshing: refreshing ?? this.refreshing,
        status: status ?? this.status,
        selectedSearch: selectedSearch ?? this.selectedSearch,
        savedSearchState: savedSearchState ?? this.savedSearchState,
      );

  @override
  List<Object?> get props =>
      [savedSearches, status, selectedSearch, savedSearchState];
}

abstract class SavedSearchFeedEvent extends Equatable {
  const SavedSearchFeedEvent();
}

class SavedSearchFeedRefreshed extends SavedSearchFeedEvent {
  const SavedSearchFeedRefreshed();

  @override
  List<Object?> get props => [];
}

class SavedSearchFeedSelectedTagChanged extends SavedSearchFeedEvent {
  const SavedSearchFeedSelectedTagChanged({
    required this.savedSearch,
  });

  final SavedSearch savedSearch;

  @override
  List<Object?> get props => [savedSearch];
}

class _RefreshDone extends SavedSearchFeedEvent {
  const _RefreshDone({
    required this.data,
  });

  final List<SavedSearch> data;

  @override
  List<Object?> get props => [data];
}

class _SavedSearchStateChanged extends SavedSearchFeedEvent {
  const _SavedSearchStateChanged({
    required this.state,
  });

  final SavedSearchState state;

  @override
  List<Object?> get props => [state];
}

class SavedSearchFeedBloc
    extends Bloc<SavedSearchFeedEvent, SavedSearchFeedState> {
  SavedSearchFeedBloc({
    required SavedSearchBloc savedSearchBloc,
  }) : super(SavedSearchFeedState.initial()) {
    on<SavedSearchFeedRefreshed>((event, emit) async {
      savedSearchBloc.add(const SavedSearchFetched());
    });

    on<SavedSearchFeedSelectedTagChanged>((event, emit) {
      emit(state.copyWith(
        selectedSearch: event.savedSearch,
      ));
    });

    on<_RefreshDone>((event, emit) {
      final data = event.data;

      if (data.isNotEmpty) {
        final searches = [
          ...data,
        ].where((e) => e.labels.isNotEmpty).toList()
          ..insert(0, SavedSearch.all());

        emit(state.copyWith(
          status: SavedSearchFeedStatus.loaded,
          selectedSearch: searches.first,
          savedSearches: searches,
        ));
      } else {
        emit(state.copyWith(
          status: SavedSearchFeedStatus.noData,
          savedSearches: [],
        ));
      }
    });

    on<_SavedSearchStateChanged>((event, emit) {
      emit(state.copyWith(
        savedSearchState: event.state,
        savedSearches: [
          SavedSearch.all(),
          ...event.state.data.where((e) => e.labels.isNotEmpty),
        ],
      ));
    });

    savedSearchBloc.stream
        .distinct()
        .listen((event) => add(_SavedSearchStateChanged(state: event)))
        .addTo(compositeSubscription);

    savedSearchBloc.stream
        .distinct()
        .pairwise()
        .where((event) =>
            (event.first.data.isEmpty && event[1].data.isNotEmpty) ||
            (event.first.data.isNotEmpty && event[1].data.isEmpty))
        .map((event) => event[1])
        .listen((event) => add(const SavedSearchFeedRefreshed()))
        .addTo(compositeSubscription);

    savedSearchBloc.stream
        .pairwise()
        .where((event) =>
            event.first.status == LoadStatus.initial &&
            event[1].status == LoadStatus.success)
        .map((event) => event[1].data)
        .listen((data) => add(_RefreshDone(data: data)))
        .addTo(compositeSubscription);
  }

  final compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}
