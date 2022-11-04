// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
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
    required this.refreshing,
    required this.status,
    required this.selectedSearch,
  });

  factory SavedSearchFeedState.initial() => SavedSearchFeedState(
        savedSearches: const [],
        refreshing: false,
        status: SavedSearchFeedStatus.initial,
        selectedSearch: SavedSearch.empty(),
      );

  final List<SavedSearch> savedSearches;
  final SavedSearchFeedStatus status;
  final bool refreshing;
  final SavedSearch selectedSearch;

  SavedSearchFeedState copyWith({
    List<SavedSearch>? savedSearches,
    bool? refreshing,
    SavedSearchFeedStatus? status,
    SavedSearch? selectedSearch,
  }) =>
      SavedSearchFeedState(
        savedSearches: savedSearches ?? this.savedSearches,
        refreshing: refreshing ?? this.refreshing,
        status: status ?? this.status,
        selectedSearch: selectedSearch ?? this.selectedSearch,
      );

  @override
  List<Object?> get props =>
      [savedSearches, refreshing, status, selectedSearch];
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

class SavedSearchFeedBloc
    extends Bloc<SavedSearchFeedEvent, SavedSearchFeedState> {
  SavedSearchFeedBloc({
    required SavedSearchRepository savedSearchRepository,
  }) : super(SavedSearchFeedState.initial()) {
    on<SavedSearchFeedRefreshed>((event, emit) async {
      await tryAsync<List<SavedSearch>>(
        action: () => savedSearchRepository.getSavedSearches(page: 1),
        onLoading: () {
          emit(state.copyWith(
            refreshing: true,
            status: SavedSearchFeedStatus.initial,
          ));
        },
        onUnknownFailure: (stackTrace, error) => emit(state.copyWith(
          refreshing: false,
          status: SavedSearchFeedStatus.failure,
        )),
        onSuccess: (data) async {
          if (data.isNotEmpty) {
            final searches = [
              ...data,
            ]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
              ..insert(0, SavedSearch.all());

            emit(state.copyWith(
              status: SavedSearchFeedStatus.loaded,
              refreshing: false,
              selectedSearch: searches.first,
              savedSearches: searches,
            ));
          } else {
            emit(state.copyWith(
              status: SavedSearchFeedStatus.noData,
              refreshing: false,
              savedSearches: [],
            ));
          }
        },
      );
    });

    on<SavedSearchFeedSelectedTagChanged>((event, emit) {
      emit(state.copyWith(
        selectedSearch: event.savedSearch,
      ));
    });
  }
}
