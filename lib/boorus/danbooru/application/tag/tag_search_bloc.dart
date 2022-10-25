// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/common/string_utils.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';

@immutable
class TagSearchState extends Equatable {
  const TagSearchState({
    required this.query,
    required this.selectedTags,
    required this.suggestionTags,
    required this.metaTagMatches,
    required this.isDone,
    required this.operator,
  });

  factory TagSearchState.initial() => const TagSearchState(
        query: '',
        selectedTags: [],
        suggestionTags: [],
        metaTagMatches: [],
        isDone: false,
        operator: FilterOperator.none,
      );
  final List<TagSearchItem> selectedTags;
  final List<AutocompleteData> suggestionTags;
  final List<Metatag> metaTagMatches;
  final String query;
  final bool isDone;
  final FilterOperator operator;

  TagSearchState copyWith({
    String? query,
    List<TagSearchItem>? selectedTags,
    List<AutocompleteData>? suggestionTags,
    List<Metatag>? metaTagMatches,
    bool? isDone,
    FilterOperator? operator,
  }) =>
      TagSearchState(
        query: query ?? this.query,
        selectedTags: selectedTags ?? this.selectedTags,
        suggestionTags: suggestionTags ?? this.suggestionTags,
        metaTagMatches: metaTagMatches ?? this.metaTagMatches,
        isDone: isDone ?? this.isDone,
        operator: operator ?? this.operator,
      );

  @override
  List<Object?> get props => [
        query,
        selectedTags,
        suggestionTags,
        metaTagMatches,
        isDone,
        operator,
      ];
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

class TagSearchNewRawStringTagSelected extends TagSearchEvent {
  const TagSearchNewRawStringTagSelected(this.tag);
  final String tag;

  @override
  List<Object?> get props => [tag];
}

class TagSearchNewRawStringTagsSelected extends TagSearchEvent {
  const TagSearchNewRawStringTagsSelected(this.tags);
  final List<String> tags;

  @override
  List<Object?> get props => [tags];
}

class TagSearchTagFromHistorySelected extends TagSearchEvent {
  const TagSearchTagFromHistorySelected(this.tags);
  final String tags;

  @override
  List<Object?> get props => [tags];
}

class TagSearchSubmitted extends TagSearchEvent {
  const TagSearchSubmitted();

  @override
  List<Object?> get props => [];
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
    required TagInfo tagInfo,
  }) : super(TagSearchState.initial()) {
    on<TagSearchChanged>(
      (event, emit) async {
        final query = event.query.trimLeft().replaceAll(' ', '_');
        if (query.isEmpty) {
          emit(state.copyWith(query: ''));

          return;
        }

        final operator = stringToFilterOperator(query.getFirstCharacter());
        if (query.length == 1 && operator != FilterOperator.none) return;

        emit(state.copyWith(
          query: query,
          operator: operator,
          metaTagMatches: tagInfo.metatags
              .where((e) => e.name.startsWith(query))
              .take(2)
              .toList(),
        ));

        await tryAsync<List<AutocompleteData>>(
          action: () =>
              autocompleteRepository.getAutocomplete(getQuery(query, operator)),
          onSuccess: (tags) async => emit(state.copyWith(
            suggestionTags: tags,
          )),
        );
      },
    );

    on<TagSearchTagFromHistorySelected>((event, emit) {
      emit(state.copyWith(
        selectedTags: [
          ...state.selectedTags,
          ...event.tags
              .split(' ')
              .map((e) => TagSearchItem.fromString(e, tagInfo)),
        ],
        query: '',
        suggestionTags: [],
      ));
    });

    on<TagSearchNewRawStringTagSelected>((event, emit) {
      emit(state.copyWith(
        selectedTags: [
          ...state.selectedTags,
          TagSearchItem.fromString(
            '${filterOperatorToString(state.operator)}${event.tag}',
            tagInfo,
          ),
        ],
        query: '',
        suggestionTags: [],
      ));
    });

    on<TagSearchNewRawStringTagsSelected>((event, emit) {
      emit(state.copyWith(
        selectedTags: [
          ...state.selectedTags,
          ...event.tags.map((tag) => TagSearchItem.fromString(
                '${filterOperatorToString(state.operator)}$tag',
                tagInfo,
              )),
        ],
        query: '',
        suggestionTags: [],
      ));
    });

    on<TagSearchNewTagSelected>((event, emit) {
      emit(state.copyWith(
        selectedTags: [
          ...state.selectedTags,
          TagSearchItem.fromString(
            '${filterOperatorToString(state.operator)}${event.tag.value}',
            tagInfo,
          ),
        ],
        query: '',
        suggestionTags: [],
      ));
    });

    on<TagSearchCleared>((event, emit) => emit(state.copyWith(
          query: '',
          suggestionTags: [],
        )));

    on<TagSearchSelectedTagRemoved>((event, emit) => emit(state.copyWith(
          selectedTags: [...state.selectedTags]..remove(event.tag),
        )));

    on<TagSearchDone>((event, emit) => emit(state.copyWith(isDone: true)));

    on<TagSearchSubmitted>((event, emit) {
      if (state.query.isEmpty) return;
      emit(state.copyWith(
        selectedTags: [
          ...state.selectedTags,
          TagSearchItem.fromString(
            state.query,
            tagInfo,
          ),
        ],
        query: '',
        suggestionTags: [],
      ));
    });
  }
}

String getQuery(String query, FilterOperator operator) {
  if (operator != FilterOperator.none) return query.substring(1);

  return query;
}
