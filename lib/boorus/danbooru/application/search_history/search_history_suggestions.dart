// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class SearchHistorySuggestionsState extends Equatable {
  const SearchHistorySuggestionsState({
    required this.histories,
  });

  factory SearchHistorySuggestionsState.initial() =>
      const SearchHistorySuggestionsState(histories: []);

  final List<SearchHistory> histories;

  SearchHistorySuggestionsState copyWith({
    List<SearchHistory>? histories,
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
    required this.character,
  });

  final String character;

  @override
  List<Object?> get props => [character];
}

class SearchHistorySuggestionsBloc
    extends Bloc<SearchHistorySuggestionsEvent, SearchHistorySuggestionsState> {
  SearchHistorySuggestionsBloc({
    required ISearchHistoryRepository searchHistoryRepository,
  }) : super(SearchHistorySuggestionsState.initial()) {
    on<SearchHistorySuggestionsFetched>((event, emit) async {
      await tryAsync<List<SearchHistory>>(
        action: () => searchHistoryRepository.getHistories(),
        onSuccess: (data) async {
          final histories = data
              .where((e) => e.query.contains(event.character))
              .take(2)
              .toList();
          emit(state.copyWith(histories: histories));
        },
      );
    });
  }
}
