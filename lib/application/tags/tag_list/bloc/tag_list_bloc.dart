import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:equatable/equatable.dart';

part 'tag_list_event.dart';
part 'tag_list_state.dart';

class TagListBloc extends Bloc<TagListEvent, TagListState> {
  final ITagRepository _tagRepository;

  TagListBloc(this._tagRepository) : super(TagListInitial());

  @override
  Stream<TagListState> mapEventToState(
    TagListEvent event,
  ) async* {
    if (event is GetTagList) {
      yield TagListLoading();
      final tags = await _tagRepository.getTagsByNameComma(
          event.tagsStringSeperatedByComma, event.page);
      yield TagListLoaded(tags);
    }
  }
}
