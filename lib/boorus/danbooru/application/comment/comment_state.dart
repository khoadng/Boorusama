// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';

class CommentState extends Equatable {
  const CommentState({
    required this.comments,
    required this.hiddenComments,
    required this.status,
  });

  factory CommentState.initial() => const CommentState(
        comments: [],
        hiddenComments: [],
        status: LoadStatus.initial,
      );

  CommentState copyWith({
    List<CommentData>? comments,
    List<CommentData>? hiddenComments,
    LoadStatus? status,
  }) =>
      CommentState(
        comments: comments ?? this.comments,
        hiddenComments: hiddenComments ?? this.hiddenComments,
        status: status ?? this.status,
      );

  final List<CommentData> hiddenComments;
  final List<CommentData> comments;
  final LoadStatus status;

  @override
  List<Object> get props => [comments, hiddenComments, status];
}
