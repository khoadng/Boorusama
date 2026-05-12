// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/comments/types.dart';

class SzurubooruComment extends Equatable implements Comment {
  const SzurubooruComment({
    required this.id,
    required this.postId,
    required this.version,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorName,
    required this.score,
    required this.ownScore,
  });

  @override
  final int id;
  final int postId;
  final int version;
  @override
  final String body;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? creatorName;
  final int score;
  final int ownScore;

  @override
  int? get creatorId => null;

  bool get isEdited => updatedAt != null;

  CommentVoteState get voteState => switch (ownScore) {
    -1 => CommentVoteState.downvoted,
    1 => CommentVoteState.upvoted,
    _ => CommentVoteState.unvote,
  };

  @override
  List<Object?> get props => [
    id,
    postId,
    version,
    body,
    createdAt,
    updatedAt,
    creatorName,
    score,
    ownScore,
  ];
}
