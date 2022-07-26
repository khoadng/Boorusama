// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';

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

class CommentSent extends CommentEvent {
  const CommentSent({
    required this.postId,
    required this.content,
    this.replyTo,
  });

  final int postId;
  final String content;
  final CommentData? replyTo;

  @override
  List<Object?> get props => [postId, content, replyTo];
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

class CommentDeleted extends CommentEvent {
  const CommentDeleted({
    required this.commentId,
    required this.postId,
  });

  final CommentId commentId;
  final int postId;

  @override
  List<Object> get props => [commentId, postId];
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
