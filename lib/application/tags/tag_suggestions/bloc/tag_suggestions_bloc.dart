import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time/time.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:equatable/equatable.dart';

part 'tag_suggestions_event.dart';
part 'tag_suggestions_state.dart';

class TagSuggestionsBloc
    extends Bloc<TagSuggestionsEvent, TagSuggestionsState> {
  final ITagRepository _tagRepository;

  TagSuggestionsBloc(this._tagRepository) : super(TagSuggestionsEmpty());

  @override
  Stream<Transition<TagSuggestionsEvent, TagSuggestionsState>> transformEvents(
      Stream<TagSuggestionsEvent> events,
      TransitionFunction<TagSuggestionsEvent, TagSuggestionsState>
          transitionFn) {
    final nonDebounceStream =
        events.where((event) => event is! TagSuggestionsChanged);

    final debounceStream =
        events.where((event) => event is TagSuggestionsChanged).debounceTime(
              100.milliseconds,
            );

    return super.transformEvents(
        MergeStream([nonDebounceStream, debounceStream]), transitionFn);
  }

  @override
  Stream<TagSuggestionsState> mapEventToState(
    TagSuggestionsEvent event,
  ) async* {
    if (event is TagSuggestionsChanged) {
      try {
        yield TagSuggestionsLoading();
        final tags = await _tagRepository.getTagsByNamePattern(
          event.tagString,
          event.page,
        );
        yield TagSuggestionsLoaded(tags);
      } catch (e) {}
    } else if (event is TagSuggestionsCleared) {
      yield TagSuggestionsEmpty();
    }
  }
}
