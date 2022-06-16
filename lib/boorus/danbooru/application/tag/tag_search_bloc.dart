// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/filter_operator.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/autocomplete/autocomplete_repository.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:boorusama/common/string_utils.dart';

@immutable
class TagSearchItem extends Equatable {
  const TagSearchItem({
    required this.tag,
    required this.operator,
  });

  final AutocompleteData tag;
  final FilterOperator operator;

  @override
  List<Object?> get props => [tag, operator];
  @override
  String toString() => '${filterOperatorToString(operator)}${tag.value}';
}

@immutable
class TagSearchState extends Equatable {
  const TagSearchState({
    required this.query,
    required this.selectedTags,
    required this.suggestionTags,
    required this.isDone,
    required this.operator,
  });

  factory TagSearchState.initial() => const TagSearchState(
        query: '',
        selectedTags: [],
        suggestionTags: [],
        isDone: false,
        operator: FilterOperator.none,
      );
  final List<TagSearchItem> selectedTags;
  final List<AutocompleteData> suggestionTags;
  final String query;
  final bool isDone;
  final FilterOperator operator;

  TagSearchState copyWith({
    String? query,
    List<TagSearchItem>? selectedTags,
    List<AutocompleteData>? suggestionTags,
    bool? isDone,
    FilterOperator? operator,
  }) =>
      TagSearchState(
        query: query ?? this.query,
        selectedTags: selectedTags ?? this.selectedTags,
        suggestionTags: suggestionTags ?? this.suggestionTags,
        isDone: isDone ?? this.isDone,
        operator: operator ?? this.operator,
      );

  @override
  List<Object?> get props =>
      [query, selectedTags, suggestionTags, isDone, operator];
}

@immutable
abstract class TagSearchEvent extends Equatable {
  const TagSearchEvent();
}

class TagSearchChanged extends TagSearchEvent {
  const TagSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class TagSearchNewTagSelected extends TagSearchEvent {
  const TagSearchNewTagSelected(this.tag);
  final AutocompleteData tag;

  @override
  List<Object?> get props => [tag];
}

class TagSearchRawStringTagSelected extends TagSearchEvent {
  const TagSearchRawStringTagSelected(this.tag);
  final String tag;

  @override
  List<Object?> get props => [tag];
}

class TagSearchCleared extends TagSearchEvent {
  const TagSearchCleared();

  @override
  List<Object?> get props => [];
}

class TagSearchSelectedTagRemoved extends TagSearchEvent {
  const TagSearchSelectedTagRemoved(this.tag);

  final TagSearchItem tag;

  @override
  List<Object?> get props => [tag];
}

class TagSearchDone extends TagSearchEvent {
  const TagSearchDone();

  @override
  List<Object?> get props => [];
}

class TagSearchBloc extends Bloc<TagSearchEvent, TagSearchState> {
  TagSearchBloc({
    required AutocompleteRepository autocompleteRepository,
  }) : super(TagSearchState.initial()) {
    on<TagSearchChanged>(
      (event, emit) async {
        final query = event.query.trim();
        if (query.isEmpty) {
          emit(state.copyWith(query: ''));
          return;
        }
        final operator = stringToFilterOperator(query.getFirstCharacter());
        if (query.length == 1 && operator != FilterOperator.none) return;

        await tryAsync<List<AutocompleteData>>(
          action: () =>
              autocompleteRepository.getAutocomplete(getQuery(query, operator)),
          onSuccess: (tags) => emit(state.copyWith(
            suggestionTags: tags,
            query: query,
            operator: operator,
          )),
        );
      },
    );

    on<TagSearchNewTagSelected>((event, emit) => emit(state.copyWith(
          selectedTags: [
            ...state.selectedTags,
            TagSearchItem(
              tag: event.tag,
              operator: state.operator,
            )
          ],
          query: '',
          suggestionTags: [],
        )));

    on<TagSearchCleared>((event, emit) => emit(state.copyWith(
          query: '',
          suggestionTags: [],
        )));

    on<TagSearchSelectedTagRemoved>((event, emit) => emit(state.copyWith(
        selectedTags: [...state.selectedTags]..remove(event.tag))));

    on<TagSearchDone>((event, emit) => emit(state.copyWith(isDone: true)));

    on<TagSearchRawStringTagSelected>((event, emit) => emit(state.copyWith(
          selectedTags: [
            ...state.selectedTags,
            TagSearchItem(
              tag: AutocompleteData(
                label: event.tag.replaceAll('_', ' '),
                value: event.tag,
              ),
              operator: state.operator,
            )
          ],
          query: '',
          suggestionTags: [],
        )));
  }
}

String getQuery(String query, FilterOperator operator) {
  if (operator != FilterOperator.none) return query.substring(1);
  return query;
}
