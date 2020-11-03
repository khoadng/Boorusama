part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class GetCommentsFromPostIdRequested extends CommentEvent {
  final int postId;

  GetCommentsFromPostIdRequested(this.postId);
}
