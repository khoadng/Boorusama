// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();
}

class CommentFetched extends CommentEvent {
  const CommentFetched({
    required this.postId,
  });

  final int postId;

  @override
  List<Object> get props => [postId];
}

class CommentUpdated extends CommentEvent {
  const CommentUpdated({
    required this.commentId,
    required this.postId,
    required this.content,
  });

  final CommentId commentId;
  final int postId;
  final String content;

  @override
  List<Object> get props => [commentId, postId, content];
}

class CommentUpvoted extends CommentEvent {
  const CommentUpvoted({
    required this.commentId,
  });

  final CommentId commentId;

  @override
  List<Object> get props => [commentId];
}

class CommentDownvoted extends CommentEvent {
  const CommentDownvoted({
    required this.commentId,
  });

  final CommentId commentId;

  @override
  List<Object> get props => [commentId];
}

class CommentVoteRemoved extends CommentEvent {
  const CommentVoteRemoved({
    required this.commentId,
    required this.commentVoteId,
    required this.voteState,
  });

  final CommentId commentId;
  final CommentVoteId commentVoteId;
  final CommentVoteState voteState;

  @override
  List<Object> get props => [commentId, commentVoteId, voteState];
}
