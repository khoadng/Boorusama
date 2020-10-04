part of 'tag_suggestions_bloc.dart';

abstract class TagSuggestionsState extends Equatable {
  const TagSuggestionsState();

  @override
  List<Object> get props => [];
}

class TagSuggestionsInitial extends TagSuggestionsState {}

class TagSuggestionsLoading extends TagSuggestionsState {}

class TagSuggestionsLoaded extends TagSuggestionsState {
  final List<Tag> tags;

  TagSuggestionsLoaded(this.tags);

  @override
  List<Object> get props => [tags];
}
