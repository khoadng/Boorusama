import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/comments/comment.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_event.dart';
part 'comment_state.dart';

part 'comment_bloc.freezed.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ICommentRepository _commentRepository;

  CommentBloc({
    @required ICommentRepository commentRepository,
  })  : _commentRepository = commentRepository,
        super(CommentState.empty());

  @override
  Stream<CommentState> mapEventToState(
    CommentEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
    );
  }

  Stream<CommentState> _mapRequestedToState(_Requested event) async* {
    yield const CommentState.loading();
    final comments =
        await _commentRepository.getCommentsFromPostId(event.postId);
    yield CommentState.fetched(comments: comments);
  }
}
