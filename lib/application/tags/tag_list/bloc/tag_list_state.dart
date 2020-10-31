part of 'tag_list_bloc.dart';

abstract class TagListState extends Equatable {
  const TagListState();

  @override
  List<Object> get props => [];
}

class TagListInitial extends TagListState {}

class TagListLoading extends TagListState {}

class TagListLoaded extends TagListState {
  final List<Tag> tags;

  TagListLoaded(this.tags);
}
