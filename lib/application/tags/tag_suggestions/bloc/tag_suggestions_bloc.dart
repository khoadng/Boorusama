import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:equatable/equatable.dart';

part 'tag_suggestions_event.dart';
part 'tag_suggestions_state.dart';

class TagSuggestionsBloc
    extends Bloc<TagSuggestionsEvent, TagSuggestionsState> {
  final ITagRepository _tagRepository;

  TagSuggestionsBloc(this._tagRepository) : super(TagSuggestionsInitial());

  @override
  Stream<TagSuggestionsState> mapEventToState(
    TagSuggestionsEvent event,
  ) async* {
    if (event is TagSuggestionsRequested) {
      try {
        yield TagSuggestionsLoading();
        final tags = await _tagRepository.getTagsByNamePattern(
            event.tagString, event.page);
        yield TagSuggestionsLoaded(tags);
      } catch (e) {}
    }
  }
}
