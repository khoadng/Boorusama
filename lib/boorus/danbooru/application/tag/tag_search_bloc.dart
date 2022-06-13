// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

@immutable
class TagSearchState extends Equatable {
  const TagSearchState({
    required this.query,
    required this.selectedTags,
    required this.suggestionTags,
    required this.isDone,
  });

  factory TagSearchState.initial() => const TagSearchState(
        query: '',
        selectedTags: [],
        suggestionTags: [],
        isDone: false,
      );
  final List<Tag> selectedTags;
  final List<Tag> suggestionTags;
  final String query;
  final bool isDone;

  TagSearchState copyWith({
    String? query,
    List<Tag>? selectedTags,
    List<Tag>? suggestionTags,
    bool? isDone,
  }) =>
      TagSearchState(
        query: query ?? this.query,
        selectedTags: selectedTags ?? this.selectedTags,
        suggestionTags: suggestionTags ?? this.suggestionTags,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [query, selectedTags, suggestionTags, isDone];
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
  final Tag tag;

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

  final Tag tag;

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
    required ITagRepository tagRepository,
  }) : super(TagSearchState.initial()) {
    on<TagSearchChanged>(
      (event, emit) async {
        if (event.query.trim().isEmpty) {
          return;
        }
        await tryAsync<List<Tag>>(
          action: () => tagRepository.getTagsByNamePattern(event.query, 1),
          onSuccess: (tags) => emit(state.copyWith(
            suggestionTags: tags,
            query: event.query,
          )),
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 100)),
    );

    on<TagSearchNewTagSelected>((event, emit) => emit(state.copyWith(
          selectedTags: [...state.selectedTags, event.tag],
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
  }
}
