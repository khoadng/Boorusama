// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/common/collection_utils.dart';
import 'package:boorusama/core/application/common.dart';

class SavedSearchState extends Equatable {
  const SavedSearchState({
    required this.data,
    required this.refreshing,
    required this.status,
  });

  factory SavedSearchState.initial() => const SavedSearchState(
        data: [],
        refreshing: false,
        status: LoadStatus.initial,
      );

  final List<SavedSearch> data;
  final LoadStatus status;
  final bool refreshing;

  SavedSearchState copyWith({
    List<SavedSearch>? data,
    bool? refreshing,
    LoadStatus? status,
  }) =>
      SavedSearchState(
        data: data ?? this.data,
        refreshing: refreshing ?? this.refreshing,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [data, refreshing, status];
}

abstract class SavedSearchEvent extends Equatable {
  const SavedSearchEvent();
}

class SavedSearchFetched extends SavedSearchEvent {
  const SavedSearchFetched();

  @override
  List<Object?> get props => [];
}

class SavedSearchCreated extends SavedSearchEvent {
  const SavedSearchCreated({
    required this.query,
    this.label,
    this.onCreated,
    this.onFailure,
  });

  final String query;
  final String? label;
  final void Function(SavedSearch data)? onCreated;
  final void Function(SavedSearchCreated event)? onFailure;

  @override
  List<Object?> get props => [query, label, onCreated, onFailure];
}

class SavedSearchDeleted extends SavedSearchEvent {
  const SavedSearchDeleted({
    required this.savedSearch,
    this.onDeleted,
    this.onFailure,
  });

  final SavedSearch savedSearch;
  final void Function(SavedSearch data)? onDeleted;
  final void Function(SavedSearchDeleted event)? onFailure;

  @override
  List<Object?> get props => [savedSearch, onDeleted, onFailure];
}

class SavedSearchUpdated extends SavedSearchEvent {
  const SavedSearchUpdated({
    required this.id,
    this.query,
    this.label,
    this.onUpdated,
    this.onFailure,
  });

  final int id;
  final String? query;
  final String? label;
  final void Function(SavedSearch data)? onUpdated;
  final void Function(SavedSearchUpdated event)? onFailure;

  @override
  List<Object?> get props => [id, query, label, onUpdated, onFailure];
}

class SavedSearchBloc extends Bloc<SavedSearchEvent, SavedSearchState> {
  SavedSearchBloc({
    required SavedSearchRepository savedSearchRepository,
  }) : super(SavedSearchState.initial()) {
    on<SavedSearchFetched>((event, emit) async {
      await tryAsync<List<SavedSearch>>(
        action: () => savedSearchRepository.getSavedSearches(page: 1),
        onLoading: () {
          emit(state.copyWith(
            refreshing: true,
            status: LoadStatus.initial,
          ));
        },
        onUnknownFailure: (stackTrace, error) =>
            emit(state.copyWith(refreshing: false, status: LoadStatus.failure)),
        onSuccess: (data) async {
          emit(state.copyWith(
            status: LoadStatus.success,
            refreshing: false,
            data: _sort(data),
          ));
        },
      );
    });

    on<SavedSearchCreated>((event, emit) async {
      await tryAsync<SavedSearch?>(
        action: () => savedSearchRepository.createSavedSearch(
          query: event.query,
          label: event.label,
        ),
        onUnknownFailure: (stackTrace, error) {
          event.onFailure?.call(event);
        },
        onSuccess: (data) async {
          if (data != null) {
            emit(state.copyWith(
              data: _sort([
                ...state.data,
                data,
              ]),
            ));

            event.onCreated?.call(data);
          } else {
            event.onFailure?.call(event);
          }
        },
      );
    });

    on<SavedSearchDeleted>((event, emit) async {
      if (!event.savedSearch.canDelete) return;

      await tryAsync<bool>(
        action: () =>
            savedSearchRepository.deleteSavedSearch(event.savedSearch.id),
        onUnknownFailure: (stackTrace, error) {
          event.onFailure?.call(event);
        },
        onSuccess: (success) async {
          if (success) {
            emit(state.copyWith(
              data: [...state.data]..remove(event.savedSearch),
            ));

            event.onDeleted?.call(event.savedSearch);
          } else {
            event.onFailure?.call(event);
          }
        },
      );
    });

    on<SavedSearchUpdated>((event, emit) async {
      await tryAsync<bool>(
        action: () => savedSearchRepository.updateSavedSearch(
          event.id,
          label: event.label,
          query: event.query,
        ),
        onUnknownFailure: (stackTrace, error) {
          event.onFailure?.call(event);
        },
        onSuccess: (success) async {
          if (success) {
            final index = state.data.indexWhere((e) => e.id == event.id);
            final newSearch = state.data[index];
            final newData = [...state.data].replaceAt(
              index,
              newSearch.copyWith(
                query: event.query,
                labels: event.label != null ? [event.label!] : null,
              ),
            );

            emit(state.copyWith(
              data: _sort(newData),
            ));

            event.onUpdated?.call(newSearch);
          } else {
            event.onFailure?.call(event);
          }
        },
      );
    });
  }
}

List<SavedSearch> _sort(List<SavedSearch> items) {
  final group = items.groupBy((d) => d.labels.isEmpty);
  final hasLabelItems = group[false] ?? [];
  final noLabelItems = group[true] ?? [];

  return [
    ...noLabelItems,
    ...hasLabelItems..sort((a, b) => a.labels.first.compareTo(b.labels.first)),
  ];
}
