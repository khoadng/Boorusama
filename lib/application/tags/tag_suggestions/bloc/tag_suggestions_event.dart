part of 'tag_suggestions_bloc.dart';

abstract class TagSuggestionsEvent extends Equatable {
  const TagSuggestionsEvent();

  @override
  List<Object> get props => [];
}

class TagSuggestionsRequested extends TagSuggestionsEvent {
  final String tagString;
  final int page;

  TagSuggestionsRequested({this.tagString, this.page});
}
