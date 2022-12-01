// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class HistorySuggestion extends Equatable {
  const HistorySuggestion({
    required this.term,
    required this.tag,
    required this.searchHistory,
  });

  final String term;
  final String tag;
  final SearchHistory searchHistory;

  @override
  List<Object?> get props => [term, tag, searchHistory];
}

class SearchHistorySuggestionsState extends Equatable {
  const SearchHistorySuggestionsState({
    required this.histories,
  });

  factory SearchHistorySuggestionsState.initial() =>
      const SearchHistorySuggestionsState(histories: []);

  final List<HistorySuggestion> histories;

  SearchHistorySuggestionsState copyWith({
    List<HistorySuggestion>? histories,
  }) =>
      SearchHistorySuggestionsState(
        histories: histories ?? this.histories,
      );

  @override
  List<Object?> get props => [histories];
}

abstract class SearchHistorySuggestionsEvent extends Equatable {
  const SearchHistorySuggestionsEvent();
}

class SearchHistorySuggestionsFetched extends SearchHistorySuggestionsEvent {
  const SearchHistorySuggestionsFetched({
    required this.text,
  });

  final String text;

  @override
  List<Object?> get props => [text];
}

class SearchHistorySuggestionsCleared extends SearchHistorySuggestionsEvent {
  const SearchHistorySuggestionsCleared();

  @override
  List<Object?> get props => [];
}

class SearchHistorySuggestionsBloc
    extends Bloc<SearchHistorySuggestionsEvent, SearchHistorySuggestionsState> {
  SearchHistorySuggestionsBloc({
    required SearchHistoryRepository searchHistoryRepository,
  }) : super(SearchHistorySuggestionsState.initial()) {
    on<SearchHistorySuggestionsFetched>((event, emit) async {
      await tryAsync<List<SearchHistory>>(
        action: () => searchHistoryRepository.getHistories(),
        onSuccess: (data) async {
          final filtered = data
              .where((e) => e.query.contains(event.text))
              .take(2)
              .toList()
            ..sort((a, b) => b.searchCount.compareTo(a.searchCount));

          final histories = filtered
              .map((e) => HistorySuggestion(
                    tag: e.query,
                    term: event.text,
                    searchHistory: e,
                  ))
              .toList();

          emit(state.copyWith(
            histories: histories,
          ));
        },
      );
    });

    on<SearchHistorySuggestionsCleared>((event, emit) {
      emit(state.copyWith(histories: []));
    });
  }
}
