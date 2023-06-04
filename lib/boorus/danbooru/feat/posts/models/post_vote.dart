// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/users/users.dart';
import 'vote_state.dart';

typedef PostVoteId = int;

class PostVote extends Equatable {
  const PostVote({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  factory PostVote.empty() => PostVote(
        id: -1,
        postId: -1,
        userId: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        score: -9999,
        isDeleted: false,
      );

  factory PostVote.local({
    required int postId,
    required int score,
  }) =>
      PostVote(
        id: -99,
        postId: postId,
        userId: -99,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        score: score,
        isDeleted: false,
      );

  final PostVoteId id;
  final int postId;
  final UserId userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int score;
  final bool isDeleted;

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        createdAt,
        updatedAt,
        score,
        isDeleted,
      ];
}

extension PostVoteX on PostVote {
  VoteState get voteState => voteStateFromScore(score);
  bool get isOptimisticUpdateVote =>
      id == PostVote.local(postId: postId, score: score).id;

  PostVote copyWith({
    PostVoteId? id,
    int? postId,
    UserId? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? score,
    bool? isDeleted,
  }) =>
      PostVote(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        score: score ?? this.score,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}
