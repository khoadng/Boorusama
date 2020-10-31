part of 'tag_list_bloc.dart';

abstract class TagListEvent extends Equatable {
  const TagListEvent();

  @override
  List<Object> get props => [];
}

class GetTagList extends TagListEvent {
  final String tagsStringSeperatedByComma;
  final int page;

  GetTagList(this.tagsStringSeperatedByComma, this.page);
}
