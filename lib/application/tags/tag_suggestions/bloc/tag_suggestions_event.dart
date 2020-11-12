part of 'tag_suggestions_bloc.dart';

abstract class TagSuggestionsEvent extends Equatable {
  const TagSuggestionsEvent();

  @override
  List<Object> get props => [];
}

class TagSuggestionsChanged extends TagSuggestionsEvent {
  final String tagString;
  final int page;

  TagSuggestionsChanged({
    @required this.tagString,
    @required this.page,
  });

  @override
  List<Object> get props => [tagString, page];
}

class TagSuggestionsCleared extends TagSuggestionsEvent {}
