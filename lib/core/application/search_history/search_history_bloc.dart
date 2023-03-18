// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/searches/searches.dart';

class SearchHistoryState extends Equatable {
  const SearchHistoryState({
    required this.histories,
    required this.filteredhistories,
    required this.currentQuery,
  });

  factory SearchHistoryState.initial() => const SearchHistoryState(
        histories: [],
        filteredhistories: [],
        currentQuery: '',
      );

  final List<SearchHistory> histories;
  final List<SearchHistory> filteredhistories;
  final String currentQuery;

  SearchHistoryState copyWith({
    List<SearchHistory>? histories,
    List<SearchHistory>? filteredhistories,
    String? currentQuery,
  }) =>
      SearchHistoryState(
        histories: histories ?? this.histories,
        filteredhistories: filteredhistories ?? this.filteredhistories,
        currentQuery: currentQuery ?? this.currentQuery,
      );

  @override
  List<Object?> get props => [histories, filteredhistories, currentQuery];
}

abstract class SearchHistoryEvent extends Equatable {
  const SearchHistoryEvent();
}

class SearchHistoryFetched extends SearchHistoryEvent {
  const SearchHistoryFetched();

  @override
  List<Object?> get props => [];
}

class SearchHistoryCleared extends SearchHistoryEvent {
  const SearchHistoryCleared();

  @override
  List<Object?> get props => [];
}

class SearchHistoryAdded extends SearchHistoryEvent {
  const SearchHistoryAdded(this.history);

  final String history;

  @override
  List<Object?> get props => [history];
}

class SearchHistoryRemoved extends SearchHistoryEvent {
  const SearchHistoryRemoved(this.history);

  final String history;

  @override
  List<Object?> get props => [history];
}

class SearchHistoryFiltered extends SearchHistoryEvent {
  const SearchHistoryFiltered(this.pattern);

  final String pattern;

  @override
  List<Object?> get props => [pattern];
}

class SearchHistoryBloc extends Bloc<SearchHistoryEvent, SearchHistoryState> {
  SearchHistoryBloc({
    required SearchHistoryRepository searchHistoryRepository,
  }) : super(SearchHistoryState.initial()) {
    on<SearchHistoryFetched>((event, emit) async {
      final histories = await searchHistoryRepository.getHistories();

      _emitHistories(
        emit,
        histories: histories,
        filteredhistories: histories,
      );
    });

    on<SearchHistoryCleared>((event, emit) async {
      final success = await searchHistoryRepository.clearAll();

      if (success) {
        emit(state.copyWith(
          histories: [],
          filteredhistories: [],
        ));
      }
    });

    on<SearchHistoryAdded>((event, emit) async {
      final histories = await searchHistoryRepository.addHistory(event.history);

      _emitHistories(
        emit,
        histories: histories,
      );

      add(SearchHistoryFiltered(state.currentQuery));
    });

    on<SearchHistoryRemoved>((event, emit) async {
      final histories =
          await searchHistoryRepository.removeHistory(event.history);

      _emitHistories(
        emit,
        histories: histories,
      );

      add(SearchHistoryFiltered(state.currentQuery));
    });

    on<SearchHistoryFiltered>((event, emit) {
      _emitHistories(
        emit,
        histories: state.histories,
        currentQuery: event.pattern,
        filteredhistories: state.histories
            .where((e) => e.query.contains(event.pattern))
            .toList(),
      );
    });
  }

  void _emitHistories(
    Emitter emit, {
    required List<SearchHistory> histories,
    List<SearchHistory>? filteredhistories,
    String? currentQuery,
  }) =>
      emit(state.copyWith(
        histories: _sortByDateDesc(histories),
        currentQuery: currentQuery,
        filteredhistories: filteredhistories != null
            ? _sortByDateDesc(filteredhistories)
            : null,
      ));
}

//TODO: should use better data structure
List<SearchHistory> _sortByDateDesc(List<SearchHistory> hist) {
  hist.sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });

  return hist;
}
