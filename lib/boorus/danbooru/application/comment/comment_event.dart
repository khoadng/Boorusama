// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';

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
  });

  final int postId;
  final String content;

  @override
  List<Object> get props => [postId, content];
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
