// Package imports:
import 'package:equatable/equatable.dart';

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
