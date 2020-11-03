import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:equatable/equatable.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ICommentRepository _commentRepository;

  CommentBloc(this._commentRepository) : super(CommentInitial());

  @override
  Stream<CommentState> mapEventToState(
    CommentEvent event,
  ) async* {
    if (event is GetCommentsFromPostIdRequested) {
      yield CommentLoading();
      final comments =
          await _commentRepository.getCommentsFromPostId(event.postId);
      yield CommentFetched(comments);
    }
  }
}
