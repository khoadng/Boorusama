// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class SearchHistoryState extends Equatable {
  const SearchHistoryState({
    required this.histories,
  });

  factory SearchHistoryState.initial() =>
      const SearchHistoryState(histories: []);

  final List<SearchHistory> histories;

  SearchHistoryState copyWith({
    List<SearchHistory>? histories,
  }) =>
      SearchHistoryState(
        histories: histories ?? this.histories,
      );

  @override
  List<Object?> get props => [histories];
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

class SearchHistoryBloc extends Bloc<SearchHistoryEvent, SearchHistoryState> {
  SearchHistoryBloc({
    required SearchHistoryRepository searchHistoryRepository,
  }) : super(SearchHistoryState.initial()) {
    on<SearchHistoryFetched>((event, emit) async {
      final histories = await searchHistoryRepository.getHistories();

      _emitHistories(emit, histories);
    });

    on<SearchHistoryCleared>((event, emit) async {
      final success = await searchHistoryRepository.clearAll();

      if (success) {
        emit(state.copyWith(histories: []));
      }
    });

    on<SearchHistoryAdded>((event, emit) async {
      final histories = await searchHistoryRepository.addHistory(event.history);

      _emitHistories(emit, histories);
    });

    on<SearchHistoryRemoved>((event, emit) async {
      final histories =
          await searchHistoryRepository.removeHistory(event.history);

      _emitHistories(emit, histories);
    });
  }

  void _emitHistories(
    Emitter emit,
    List<SearchHistory> histories,
  ) =>
      emit(state.copyWith(
        histories: _sortByDateDesc(histories),
      ));
}

//TODO: should use better data structure
List<SearchHistory> _sortByDateDesc(List<SearchHistory> hist) {
  hist.sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });

  return hist;
}
