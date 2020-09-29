part of 'post_list_bloc.dart';

@immutable
abstract class PostListEvent extends Equatable {}

class GetPost extends PostListEvent {
  final String tagString;
  final int page;

  GetPost(this.tagString, this.page);

  @override
  List<Object> get props => [tagString, page];
}
